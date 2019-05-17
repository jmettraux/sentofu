
require 'json'
require 'yaml'
require 'base64'
require 'ostruct'
require 'net/http'

require 'sentifi/http'
require 'sentifi/api'


module Sentifi

  VERSION = '0.1.0'

  Dir[File.join(__dir__, 'sentifi/sentifi-*.yaml')].each do |fpath|

    Sentifi::Api.make(YAML.load(File.read(fpath)))
  end

#  class << self
#
#    def make_api(spec, name)
#
#      spec['paths'].keys
#    end
#
#    #Dir[File.join(
#    Dir[File.join(__dir__, 'sentifi/sentifi-*.yaml')].each do |fpath|
#
#      spec = YAML.load(File.read(fpath))
#
#    end
#  end
end


if $0 == __FILE__

  #p Time.now
  #t = Sentifi.fetch_token
  #pp t.to_h
  #p [ t.expires_in / 3600 / 24, :days ]

  #y = YAML.load(File.read(File.join(File.dirname(__FILE__), 'sentifi/sentifi-api-docs-sentifi-intelligence_company_api-1.0.0-swagger.yaml')))
  #pp y['paths'].keys

  #pp Sentifi.company
  #pp Sentifi.markets
end

