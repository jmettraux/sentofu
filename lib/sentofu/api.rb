
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
        define_singleton_method(:[]) { |i| fetch(point, i) }
      else
        define_singleton_method(segment) { fetch(point, nil) }
      end
    end

    protected

    def fetch(point, index)

p [ :fetch, index ]
fail "FETCH"
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

