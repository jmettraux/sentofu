
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

        expect(Sentofu.common.spec[:meta]).to eq(nil)

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
end

