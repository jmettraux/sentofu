
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

        OpenStruct.new(JSON.parse(res.body))
      end

      def get(uri)

        u = URI(uri)
        res = make_http(u).request(make_get_req(u))

        res.body
      end

      protected

      def make_http(uri)

        t = Net::HTTP.new(uri.host, uri.port)
        t.use_ssl = (uri.scheme == 'https')

        t
      end

      def make_get_req(uri)

        req = Net::HTTP::Get.new(uri.path)
        def req.set_header(k, v); @header[k] = [ v ]; end

        req.set_header('User-Agent', "Sentofu #{Sentofu::VERSION}")
        req.set_header('Content-Type', 'application/json')
        #req.add_field('Authorization', a)

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
end

