
module Sentofu

  class Resource

    attr_reader :parent, :segment

    def initialize(parent, segment)

      @parent = parent
      @segment = segment
      @children = {}
    end

    def add_segment(segment)

      m = segment.match(/\A\{([^}]+)\}\z/)
      mth = m ? :[] : segment

      return @children[mth] if @children[mth]

      if mth == :[]
        @children[:[]] = res = Sentofu::Resource.new(self, m[1])
        define_singleton_method(:[]) { |i| res.index = i; res }
        res
      else
        @children[mth] = res = Sentofu::Resource.new(self, segment)
        define_singleton_method(mth) { res }
        res
      end
    end

    def add_leaf_segment(segment, point)

      if m = segment.match(/\A\{([^}]+)\}\z/)
        define_singleton_method(:[]) { |index, query={}|
          fetch(segment, point, index, query) }
      else
        define_singleton_method(segment) { |query={}|
          fetch(segment, point, nil, query) }
      end
    end

    protected

    def fetch(segment, point, index, query)

#p [ :fetch, segment, '(point)', index, query ]
#p path(segment)
#pp point
      self.index = index if index

      validate_query_parameters(point, query)

      return query if query[:debug_query]

nil
    end

    def path(segment=nil)

      segment ||= self.segment
      segment = segment.gsub(/_/, '-')

      if parent
        File.join(parent.send(:path), segment)
      else
        '/' + segment
      end
    end

    def validate_query_parameters(point, query)

      point['get']['parameters']
        .select { |pa| pa['in'] == 'query' }
        .each { |pa|
#pp pa
          k = (pa[:key] ||= pa['name'].gsub(/-/, '_').to_sym)

          fail ArgumentError.new(
            "missing query parameter #{k.inspect}"
          ) if pa['required'] == true && !query.has_key?(k)

          sch = pa['schema']
          enu = sch['enum']

          v = query[k]
          v = v.to_s if v.is_a?(Symbol)

          fail ArgumentError.new(
            "value #{v.inspect} for #{k.inspect} not present in #{enu.inspect}"
          ) if v && enu && ! enu.include?(v)
            }
    end
  end

  class Api < Resource

    attr_reader :spec

    def initialize(spec, name)

      super(nil, nil)

      @spec = spec
      @name = name

#puts "================== #{name}"
      spec['paths'].each do |path, point|

#p path
        re = self
        pas = path.split('/').collect { |s| s.gsub(/-/, '_') }
        pas.shift if pas.first == ''
        pas[0..-2].each do |pa|
          re = re.add_segment(pa)
        end
        re.add_leaf_segment(pas.last, point)
      end
    end

    class << self

      def make(api_spec)

        name =
          api_spec['info']['title'].split(' - ').last[0..-4].strip
            .gsub(/([a-z])([A-Z])/) { |_| $1 + '_' + $2.downcase }
            .gsub(/([A-Z])/) { |c| c.downcase }

        api = Sentofu::Api.new(api_spec, name)
        (class << Sentofu; self; end).define_method(name) { api }
      end
    end
  end
end

