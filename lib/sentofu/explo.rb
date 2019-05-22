
module Sentofu

  class << self

    def list_apis

      detail_apis['apis']
        .collect { |meta|

          ps = meta['properties']

          u = ps.find { |p| p['type'] == 'Swagger' }['url']
          v = ps.find { |p| p['type'] == 'X-Version' }['value']

          m = u.match(/intelligence_([^_]+)_api/)
          n = m ? m[1] : meta['name']

          d = meta['description']

          { 'n' => n, 'v' => v, 'd' => d, 'u' => u } }
    end

    def detail_apis

      Sentofu::Http.get_and_parse(
        'https://api.swaggerhub.com/apis/sentifi-api-docs/')
    end

#-	curl https://api.swaggerhub.com/apis/sentifi-api-docs/sentifi-intelligence_company_api/1.0.0/swagger.yaml > api_company.yaml
    def dump_apis

      puts

      list_apis.each do |h|
        n = h['n']; n = "auth" if n.match(/auth/i)
        fn = "api_#{n}_#{h['v']}.yaml"
        res = Sentofu::Http.get(h['u'] + '/swagger.yaml')
        File.open(fn, 'wb') { |f| f.write(res.body) }
        puts "  wrote #{fn}"
      end
    end

    #protected
  end
end

