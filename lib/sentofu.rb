
require 'json'
require 'yaml'
require 'time'
require 'base64'
require 'ostruct'
require 'net/http'

require 'sentofu/http'
require 'sentofu/api'
require 'sentofu/explo'


module Sentofu

  VERSION = '0.1.0'

  USER_AGENT =
    "Sentofu #{Sentofu::VERSION} - " +
    [ 'Ruby', RUBY_VERSION, RUBY_RELEASE_DATE, RUBY_PLATFORM ].join(' ')
  @user_agent =
    USER_AGENT

  @auth_uri = nil
  @apis = {}

  class << self

    attr_reader :auth_uri, :apis
    attr_accessor :user_agent

    def init(versions=%w[ common:1.0.0 company:1.0.0 markets:1.0.0 ])

      vers = split_versions(versions)

      vers << %w[ auth * ] unless vers.find { |n, _| n == 'auth' }

      vers.each do |api_name, ver_pattern|

        doc_uri =
          'https://api.swaggerhub.com/apis/sentifi-api-docs' +
          (api_name == 'auth' ?
            '/sentifi-api_o_auth_2_authentication_and_authorization/' :
            "/sentifi-intelligence_#{api_name}_api/")

        metas = Sentofu::Http.get_and_parse(doc_uri)

        v, u, meta = metas['apis']
          .collect { |m|
            prs = m['properties']
            [ prs.find { |pr| pr['type'] == 'X-Version' }['value'],
              prs.find { |pr| pr['type'] == 'Swagger' }['url'],
              m ] }
          .select { |v, _, _| version_match(v, ver_pattern) }
          .sort_by(&:first)
          .first

        spec = Sentofu::Http.get_and_parse(u)
        spec[:meta] = meta

        if api_name == 'auth'
          @auth_uri = spec['servers'][0]['url'] + spec['paths'].keys.first
        else
          api = Sentofu::Api.new(api_name, spec)
          Sentofu.define_singleton_method(api_name) { api }
          @apis[api_name] = api
        end
      end
    end

    protected

    def split_versions(vs)

      case vs
      when Array then vs.collect { |v| split_version(v) }
      when String then vs.split(';').collect { |v| split_version(v) }
      else vs
      end
    end

    def split_version(v)

      v.is_a?(Array) ? v : v.split(':').collect(&:strip)
    end

    def version_match(version, pattern)

      ves = version.split('.')
      pattern.split('.').each do |pa|
        ve = ves.shift
        next if pa == 'x' || pa == '*'
        return false if ve != pa
      end

      true
    end
  end
end


if $0 == __FILE__

  #p Time.now
  #t = Sentofu::Http.fetch_token
  #pp t.to_h
  #p [ t.expires_in / 3600 / 24, :days ]

  #y = YAML.load(File.read(File.join(File.dirname(__FILE__), 'sentifi/sentifi-api-docs-sentifi-intelligence_company_api-1.0.0-swagger.yaml')))
  #pp y['paths'].keys

  #p Sentofu.company.class
  #p Sentofu.company.topic_search
  #pp Sentofu.markets

  #puts Sentofu.company.paths.keys

  t0 = Time.now
  Sentofu.init
  puts "took #{Time.now - t0}s..."
end

