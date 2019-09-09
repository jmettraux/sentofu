
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

      expect(h[:uri]).to eq('https://apis.sentifi.com/v1/markets/events')
      expect(h[:code]).to eq(404)
      expect(h[:message]).to eq('Not Found')
      expect(h[:error_class]).to eq('RuntimeError')
      expect(h[:error_message]).to match('something went wrong')
    end
  end

  describe 'PROXY_REX' do

    {
      'user:pass@host.example.com:123' =>
        { un: 'user', pw: 'pass', ho: 'host.example.com', pt: 123 },
      'host.example.com:123' =>
        { ho: 'host.example.com', pt: 123 },
      'host.example.com' =>
        { ho: 'host.example.com' },
      'http://user:pass@host.example.com:123' =>
        { un: 'user', pw: 'pass', ho: 'host.example.com', pt: 123 },
      'http://host.example.com:123' =>
        { ho: 'host.example.com', pt: 123 },
      'http://host.example.com' =>
        { ho: 'host.example.com' },
      'https://host.example.com' =>
        { ho: 'host.example.com', pt: 443 },
      'https://host.example.com:8443' =>
        { ho: 'host.example.com', pt: 8443 },
      'http://ERABLE\ERLR0SRVSvc_STG - UAT:pass@sg.example.com:8080' =>
        { un: 'ERABLE\ERLR0SRVSvc_STG - UAT', pw: 'pass',
          ho: 'sg.example.com', pt: 8080 },

    }.each do |uri, params|

      it "extracts #{params.inspect} out of #{uri.inspect}" do

        m = Sentofu::Http::PROXY_REX.match(uri)

        ps = { ho: m[6] }
        ps[:pt] = m[8].to_i if m[8]
        ps[:un] = m[3] if m[3]
        ps[:pw] = m[5] if m[5]
        ps[:pt] ||= 443 if m[1] && m[1] == 'https://'

        expect(ps).to eq(params)
      end
    end
  end

  describe "ENV['sentofu_http_proxy']" do

    after :each do
      ENV.delete('sentofu_http_proxy')
    end

    it 'points sentofu to a HTTP proxy' do

      ENV['sentofu_http_proxy'] = 'http://bob:pass@proxy.example.com'

      expect {
        Sentofu::Http.fetch_token
      }.to raise_error(
        SocketError,
        /\AFailed to open TCP connection to proxy\.example\.com:80/
      )
    end

    it 'points sentofu to a HTTP proxy' do

      ENV['sentofu_http_proxy'] = 'https://bob:pass@proxy.example.com'

      expect {
        Sentofu::Http.fetch_token
      }.to raise_error(
        SocketError,
        /\AFailed to open TCP connection to proxy\.example\.com:443/
      )
    end
  end
end

