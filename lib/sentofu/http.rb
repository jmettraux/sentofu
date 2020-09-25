
module Sentofu

  module Http

    PROXY_REX = /\A(https?:\/\/)?(([^:@]+)(:([^@]+))?@)?([^:]+)(:(\d+))?\z/

    class << self

      def fetch_token(credentials=nil)

        cs = narrow_credentials(credentials)

        a = Base64.encode64("#{cs.id}:#{cs.secret}").strip

        req = Net::HTTP::Post.new(Sentofu.auth_uri)
        req.add_field('Content-Type', 'application/json')
        req.add_field('Authorization', a)

        req.body = JSON.dump(
          grant_type: 'password', username: cs.user, password: cs.pass)

        Sentofu::Token.new(request(Sentofu.auth_uri, req))
      end

      def get(uri, token=nil)

        request(uri, make_get_req(uri, token))
      end

      def make_net_http(uri)

        http =
          if pm = PROXY_REX.match(ENV['sentofu_http_proxy'] || '')

            port = pm[8] ? pm[8].to_i : nil
            port ||= 443 if pm[1] && pm[1] == 'https://'

#p [ pm[6], port, pm[3], pm[5] ]
            Net::HTTP.new(
              uri.host, uri.port,
              pm[6], port,   # proxy host and port
              pm[3], pm[5])  # proxy user and pass

          else

            Net::HTTP.new(
              uri.host, uri.port)
          end

        # Nota Bene:
        # even if ENV['sentofu_http_proxy'], ENV['http_proxy'] could kick in

        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = Sentofu.ssl_verify_mode
        end

        http
      end

      def request(uri, req)

        u = uri.is_a?(String) ? URI(uri) : uri

        t0 = monow

        http = make_net_http(u)
#t.set_debug_output($stdout) if u.to_s.match?(/search/)

        res = http.request(req)

        fail "request returned a #{res.class} and not a Net::HTTPResponse" \
          unless res.is_a?(Net::HTTPResponse)

        class << res
          attr_accessor :_elapsed
          def _headers; each_header.inject({}) { |h, (k, v)| h[k] = v; h }; end
        end
        res._elapsed = monow - t0

        res
      end

      def get_and_parse(uri, token=nil)

        res = get(uri, token)

        fail 'something went wrong' \
          unless res.header['content-type'].match?(/^application\/json(;|$)/)

        JSON.parse(res.body)
          .merge!(
            _headers: res._headers,
            _elapsed: res._elapsed)

      rescue => err

        { uri: uri,
          code: (res.code.to_i rescue nil),
          headers: (res._headers rescue nil),
          message: (WEBrick::HTTPStatus.reason_phrase(res.code) rescue nil),
          error_class: err.class.to_s,
          error_message: err.message,
          error_trace: err.backtrace,
          body: ((res.body.index('</html>') ? '<html>' : res.body) rescue nil) }
      end

      protected

      def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end

      def make_get_req(uri, token)

        req = Net::HTTP::Get.new(uri.to_s)
        req.instance_eval { @header.clear }
        def req.set_header(k, v); @header[k] = [ v ]; end

        req.set_header('User-Agent', Sentofu.user_agent)
        req.set_header('Accept', 'application/json')

        req.set_header('Authorization', token.header_value) if token

        req
      end

      def narrow_credentials(o)

        case o
        when OpenStruct then o
        when Hash then OpenStruct.new(o)
        when NilClass then load_credentials
        when String then load_credentials(o)
        else fail ArgumentError.new( "no credentials in a #{o.class}")
        end
      end

      def load_credentials(fname='.sentifi-credentials.yaml')

        OpenStruct.new(YAML.load(File.read(fname)))
      end
    end
  end

  class Token

    def initialize(res)

      @h = JSON.parse(res.body)
      @h[:_elapsed] = res._elapsed
      @expires_at = Time.now + @h['expires_in']
    end

    def not_expired?

      Time.now < @expires_at
    end

    def header_value

      'Bearer ' + @h['access_token']
    end
  end
end

