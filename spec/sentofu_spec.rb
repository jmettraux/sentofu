
#
# Specifying sentofu
#
# Wed May 22 07:56:28 JST 2019
#

require 'spec_helper'


describe Sentofu do

  describe '.version_match' do

    {
      [ '3.0.1', '*' ] => true,
      [ '3.0.1', 'x' ] => true,
      [ '3.0.1', '3.x' ] => true,
      [ '3.0.1', '3.*' ] => true,
      [ '3.0.1', '3.0' ] => true,
      [ '3.0.1', '3.0.0' ] => false,
      [ '3.0.1', '3.1.x' ] => false,
      [ '3.0.1', '4.x' ] => false,
      [ '3.0.1', '4.*' ] => false,

    }.each do |(ver, pat), res|

      it "returns #{res} for #{ver.inspect} against #{pat.inspect}" do

        module Sentofu; class << self; public :version_match; end; end

        expect(Sentofu.version_match(ver, pat)).to eq(res)
      end
    end
  end

  describe '.init' do

    context 'directory' do

      after :each do

        Sentofu.init
      end

      it 'inits from api_company_1.0.0.yaml and friends' do

        expect(Sentofu.common.spec[:meta]).not_to eq(nil)

        Sentofu.init('.')

        expect(
          Sentofu.common.spec[:meta]
        ).to eq({
          modified: '2019-05-29T03:21Z',
          name: 'common',
          path: './api_common_1.0.0.yaml',
          version: '1.0.0'
        })

        expect(Sentofu.company.version).to eq('1.0.0')
        expect(Sentofu.company.modified).to eq(Time.parse('2019-05-29T03:21Z'))

        r = Sentofu.company.query('/topic-search', keyword: 'ibm')

        expect(r['data'].collect { |e| e['id'] }).to include(128)
      end

      it 'fails if the target dir does not contain any api_*.yaml files' do

        expect {
          Sentofu.init('lib')
        }.to raise_error(
          RuntimeError, 'no api yaml files under "lib"'
        )
      end
    end
  end

  describe '.on_response' do

    after :each do

      module Sentofu
        class << self
          remove_method(:on_response)
        end
      end
    end

    it 'is called if present' do

      def Sentofu.on_response(res)
        res[:seen] = 1
      end
        #
      #Sentofu.define_singleton_method(:on_response) do |res|
      #  res[:seen] = 1
      #end
        #
      #module Sentofu
      #  def self.on_response(res)
      #    res[:seen] = 1
      #  end
      #end

      r = Sentofu.company.query('/topic-search', keyword: 'ibm')
      expect(r[:seen]).to eq(1)

      r = Sentofu.company.topic_search(keyword: 'ibm')
      expect(r[:seen]).to eq(1)
    end
  end
end

