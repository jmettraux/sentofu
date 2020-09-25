
require 'json'
require 'yaml'
require 'time'
require 'base64'
require 'webrick' # for the http code to message mapping
require 'ostruct'
require 'openssl'
require 'net/http'

require 'sentofu/http'
require 'sentofu/api'
require 'sentofu/explo'


module Sentofu

  VERSION = '0.5.5'

  USER_AGENT =
    "Sentofu #{Sentofu::VERSION} - " +
    [ 'Ruby', RUBY_VERSION, RUBY_RELEASE_DATE, RUBY_PLATFORM ].join(' ')
  @user_agent =
    USER_AGENT

  @auth_uri = nil
  @apis = {}
  @ssl_verify_mode = OpenSSL::SSL::VERIFY_PEER

  class << self

    attr_reader :auth_uri, :apis
    attr_accessor :user_agent, :ssl_verify_mode

    def init(versions=%w[ common:1.0.0 company:1.0.0 markets:1.0.0 ])

      if versions.is_a?(String) && File.directory?(versions)
        init_from_dir(versions)
      else
        init_from_swagger(versions)
      end
    end

    def credentials=(cs)

      apis.each { |_, api| api.credentials = cs }
    end

    protected

    def init_from_dir(dir)

      paths = Dir[File.join(dir, 'api_*.yaml')]

      fail RuntimeError.new("no api yaml files under #{dir.inspect}") \
        if paths.empty?

      paths.each do |path|

        m = path.match(/api_([^_]+)_(\d+(?:\.\d+)*)\.yaml\z/)
        next unless m

        api_name = m[1]
        api_version = m[2]

        api_spec = YAML.load(File.read(path))

        api_spec[:meta] = {
          name: api_name,
          version: api_version,
          path: path,
          modified: File.mtime(path).utc.strftime('%FT%RZ') }

        init_api(api_name, api_spec)
      end
    end

    def init_from_swagger(versions)

      vers = split_versions(versions)

      vers << %w[ auth * ] unless vers.find { |n, _| n == 'auth' }

      vers.each do |api_name, ver_pattern|

        doc_uri =
          'https://api.swaggerhub.com/apis/sentifi-api-docs' +
          (api_name == 'auth' ?
            '/sentifi-api_o_auth_2_authentication_and_authorization/' :
            "/sentifi-intelligence_#{api_name}_api/")

        metas = Sentofu::Http.get_and_parse(doc_uri)

        ver, mod, url, meta = metas['apis']
          .collect { |m|
            prs = m['properties']
            [ prs.find { |pr| pr['type'] == 'X-Version' }['value'],
              prs.find { |pr| pr['type'] == 'X-Modified' }['value'],
              prs.find { |pr| pr['type'] == 'Swagger' }['url'],
              m ] }
          .select { |v, _, _, _| version_match(v, ver_pattern) }
          .sort_by(&:first)
          .first

        meta[:name] = api_name
        meta[:version] = ver
        meta[:url] = url
        meta[:modified] = mod

        api_spec = Sentofu::Http.get_and_parse(url)
        api_spec[:meta] = meta

        init_api(api_name, api_spec)
      end
    end

    def init_api(name, spec)

      if name == 'auth'
        @auth_uri = spec['servers'][0]['url'] + spec['paths'].keys.first
      else
        api = Sentofu::Api.new(name, spec)
        Sentofu.define_singleton_method(name) { api }
        @apis[name] = api
      end
    end

    def split_versions(vs)

      case vs
      when Array
        vs
          .select { |v| v.strip.length > 0 }
          .collect { |v| split_version(v) }
      when String
        vs.split(/[,;]/)
          .select { |v| v.strip.length > 0 }
          .collect { |v| split_version(v) }
      else
        vs
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

