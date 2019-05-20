
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

  auth_spec =
    Sentofu::Http.get_and_parse(
	 'https://api.swaggerhub.com/apis/sentifi-api-docs/' +
     'sentifi-api_o_auth_2_authentication_and_authorization/1.0.0/')
  AUTH_URI =
    auth_spec['servers'][0]['url'] + auth_spec['paths'].keys.first

# TODO read local if SENTOFU_API_SPEC_DIR present
  %w[ company markets ].each do |api_name|

    Sentofu::Api.make(
      Sentofu::Http.get(
	    "https://api.swaggerhub.com/apis/sentifi-api-docs/" +
        "sentifi-intelligence_#{api_name}_api/1.0.0/"))
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
end

