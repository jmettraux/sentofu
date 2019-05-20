
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
  p Sentofu.company.topic_search
  #pp Sentofu.markets
end

