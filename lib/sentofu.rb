
require 'json'
require 'yaml'
require 'base64'
require 'ostruct'
require 'net/http'

require 'sentofu/http'
require 'sentofu/api'


module Sentofu

  VERSION = '0.1.0'

  Dir[File.join(__dir__, 'sentofu/sentifi-*.yaml')].each do |fpath|

    Sentofu::Api.make(YAML.load(File.read(fpath)))
  end
end


if $0 == __FILE__

  #p Time.now
  #t = Sentofu::Http.fetch_token
  #pp t.to_h
  #p [ t.expires_in / 3600 / 24, :days ]

  #y = YAML.load(File.read(File.join(File.dirname(__FILE__), 'sentifi/sentifi-api-docs-sentifi-intelligence_company_api-1.0.0-swagger.yaml')))
  #pp y['paths'].keys

  p Sentofu.company.class
  p Sentofu.company.topic_search
  #pp Sentofu.markets
end

