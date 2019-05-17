
module Sentifi

  class Api

    def initialize(spec, name)

      @spec = spec
      @name = name

      p [ name ]
      spec['paths'].each do |path, value|
        p path
      end
    end

    protected

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

