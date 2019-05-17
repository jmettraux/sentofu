
require 'json'
require 'yaml'
require 'base64'
require 'ostruct'
require 'net/http'


module Sentifi

  VERSION = '0.1.0'

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

    def make_api(spec, name)

      spec['paths'].keys
    end

    #Dir[File.join(
    Dir[File.join(__dir__, 'sentifi/sentifi-*.yaml')].each do |fpath|

      spec = YAML.load(File.read(fpath))

      name =
        spec['info']['title'].split(' - ').last[0..-4].strip
          .gsub(/([a-z])([A-Z])/) { |_| $1 + '_' + $2.downcase }
          .gsub(/([A-Z])/) { |c| c.downcase }

      api = Sentifi.send(:make_api, spec, name)
      define_method(name) { api }
    end
  end
end


if $0 == __FILE__

  #p Time.now
  #t = Sentifi.fetch_token
  #pp t.to_h
  #p [ t.expires_in / 3600 / 24, :days ]

  #y = YAML.load(File.read(File.join(File.dirname(__FILE__), 'sentifi/sentifi-api-docs-sentifi-intelligence_company_api-1.0.0-swagger.yaml')))
  #pp y['paths'].keys

  pp Sentifi.company
  #pp Sentifi.markets
end

