
require 'json'
require 'yaml'
require 'time'
require 'base64'
require 'ostruct'
require 'net/http'

require 'sentofu/http'
require 'sentofu/api'


module Sentofu

  VERSION = '0.1.0'

  USER_AGENT =
    "Sentofu #{Sentofu::VERSION} - " +
    [ 'Ruby', RUBY_VERSION, RUBY_RELEASE_DATE, RUBY_PLATFORM ].join(' ')
  @user_agent =
    USER_AGENT

  class << self

    attr_reader :auth_uri, :apis
    attr_accessor :user_agent
  end

  @auth_uri = nil
  @apis = {}

  Sentofu::Http.get_and_parse(
    'https://api.swaggerhub.com/apis/sentifi-api-docs/')['apis']
      .each { |meta|

        name =
          case meta['name']
          when /OAuth/i then :auth
          when / - (.+) API\z/ then $1.downcase.gsub(/ +/, '-')
          else nil
          end
        next unless name

        spec_uri = meta['properties']
          .find { |pr| pr['type'] == 'Swagger' }['url']
        spec = Sentofu::Http.get_and_parse(spec_uri)
        spec[:meta] = meta

        if name == :auth
          @auth_uri = spec['servers'][0]['url'] + spec['paths'].keys.first
        else
          api = Sentofu::Api.new(name, spec)
          Sentofu.define_singleton_method(name) { api }
          @apis[name] = api
        end }
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
end

