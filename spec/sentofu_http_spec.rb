
#
# Specifying sentofu
#
# Mon May 20 11:03:50 JST 2019
#

require 'spec_helper'


describe Sentofu::Http do

  describe '.fetch_token' do

    it 'returns a Sentofu::Token instance' do

      t = Sentofu::Http.fetch_token

      expect(t.class).to eq(Sentofu::Token)
    end
  end
end

