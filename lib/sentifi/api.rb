
module Sentifi

  class Resource

    attr_reader :name

    def initialize(parent, name, point)

      @parent = parent
      @name = name
      #@point = point
    end

    def add_path(path); add(path, nil); end
    def add_point(path, point); add(path, point); end

    def [](index)
# TODO
    end

    protected

    def add(path, point)

      res = Sentifi::Resource.new(self, path.first, point)

      s = (class << self; self; end)

      path0 = path.first.gsub(/-/, '_')

      if point
        s.define_method(path0) { |key=nil, opts={}|
          "nada" }
      else
        s.define_method(path0) { |key=nil, opts={}|
          if path[1]
            res[opts[path[1]]]
          else
            res
          end }
      end

      res
    end
  end

  class Api < Resource

    attr_reader :spec

    def initialize(spec, name)

      super(nil, name, nil)

      @spec = spec

puts "================== #{name}"
      spec['paths'].each do |path, point|

p path
        re = self
        pas = split_path(path)

        pas[0..-2].each do |pa|
          re = re.add_path(pa)
        end

        re.add_point(pas.last, point)
      end
    end

    protected

    def split_path(path)

      r = []

      ps = path.split('/')[1..-1]
      while ps.any?
        pa = ps.shift
        pb = ps.first
        if m = pb && pb.match(/\A\{([^}]+)\}\z/)
          ps.shift
          r << [ pa, m[1] ]
        else
          r << [ pa ]
        end
      end

      r
    end

    class << self

      def make(api_spec)

        name =
          api_spec['info']['title'].split(' - ').last[0..-4].strip
            .gsub(/([a-z])([A-Z])/) { |_| $1 + '_' + $2.downcase }
            .gsub(/([A-Z])/) { |c| c.downcase }

        api = Sentifi::Api.new(api_spec, name)
        (class << Sentifi; self; end).define_method(name) { api }
      end

      #protected
    end
  end
end

