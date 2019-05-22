
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
end

