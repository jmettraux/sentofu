
module Sentofu

  module Http

    class << self

      def fetch_token(credentials=nil)

        u = URI(Sentofu.auth_uri)

        cs = narrow_credentials(credentials)

        a = Base64.encode64("#{cs.id}:#{cs.secret}").strip
        #p a

        req = Net::HTTP::Post.new(u.path)
        req.add_field('Content-Type', 'application/json')
        req.add_field('Authorization', a)

        req.body = JSON.dump(
          grant_type: 'password', username: cs.user, password: cs.pass)

        res = make_http(u).request(req)

        Sentofu::Token.new(res)
      end

      def get(uri, token=nil)

        u = URI(uri)

#t0 = Time.now
        res = make_http(u).request(make_get_req(u, token))
        #def res.headers; r = {}; each_header { |k, v| r[k] = v }; r; end
#puts "*** GET #{uri} took #{Time.now - t0}s"

        res
      end

      def get_and_parse(uri, token=nil)

        JSON.parse(get(uri, token).body)
      end

      protected

      def make_http(uri)

#p uri.to_s
        t = Net::HTTP.new(uri.host, uri.port)
        t.use_ssl = (uri.scheme == 'https')
#t.set_debug_output($stdout) if uri.to_s.match(/ibm/)
#t.set_debug_output($stdout) if uri.to_s.match(/docs/)

        t
      end

      def make_get_req(uri, token)

        req = Net::HTTP::Get.new(uri.to_s)
        req.instance_eval { @header.clear }
        def req.set_header(k, v); @header[k] = [ v ]; end

        req.set_header('User-Agent', Sentofu.user_agent)
        req.set_header('Accept', 'application/json')

        req.set_header('Authorization', token.header_value) if token
#pp req.instance_variable_get(:@header)

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

