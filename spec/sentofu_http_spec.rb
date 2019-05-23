
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

  describe '.get_and_parse' do

    it 'returns an error message when it cannot parse the message' do

      h = Sentofu::Http.get_and_parse(
        'https://apis.sentifi.com/v1/markets/events')

      expect(h[:code]).to eq(404)
      expect(h[:message]).to eq('Not Found')
      expect(h[:error_class]).to eq('JSON::ParserError')
      expect(h[:error_message]).to match(/unexpected token at /)
    end
  end
end

