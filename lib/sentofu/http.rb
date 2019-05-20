
module Sentofu

  module Http

    HOST = 'apis.sentifi.com'

    class << self

      def fetch_token(credentials=nil)

        cs = narrow_credentials(credentials)

        a = Base64.encode64("#{cs.id}:#{cs.secret}").strip
        #p a

        req = Net::HTTP::Post.new('/v1/oauth/token')
        req.add_field('Content-Type', 'application/json')
        req.add_field('Authorization', a)

        req.body = JSON.dump(
          grant_type: 'password', username: cs.user, password: cs.pass)

        res = request(req)
        #pp res

        Sentofu::Token.new(res)
      end

      def get(uri, token=nil)

        u = URI(uri)
        res = make_http(u).request(make_get_req(u, token))

        res.body
      end

      protected

      def make_http(uri)

#p uri.to_s
        t = Net::HTTP.new(uri.host, uri.port)
        t.use_ssl = (uri.scheme == 'https')
#t.set_debug_output($stdout) if uri.to_s.match(/ibm/)

        t
      end

      def make_get_req(uri, token)

        req = Net::HTTP::Get.new(uri.to_s)
        req.instance_eval { @header.clear }
        def req.set_header(k, v); @header[k] = [ v ]; end

        req.set_header('User-Agent', "Sentofu #{Sentofu::VERSION}")
        req.set_header('Accept', 'application/json')

        req.set_header('Authorization', token.header_value) if token
#pp req.instance_variable_get(:@header)

        req
      end

      def request(req)

        t = Net::HTTP.new(HOST, 443)
        t.use_ssl = true
        #t.verify_mode = OpenSSL::SSL::VERIFY_NONE # avoid

        t.request(req)
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

