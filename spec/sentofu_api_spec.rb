
#
# Specifying sentofu
#
# Sun May 19 07:11:11 JST 2019
#

require 'spec_helper'


describe Sentofu::Api do

  describe 'fetching' do

    context 'parameter checking' do

      it 'fails if a required query parameter is missing' do

        expect {
          Sentofu.company
            .topic_search
        }.to raise_error(
          ArgumentError,
          'missing query parameter :keyword'
        )
      end

      it 'fails if an enum parameter is off' do

        expect {
          Sentofu.company
            .topic_search(keyword: 'blah', category: 'horticulture')
        }.to raise_error(
          ArgumentError,
          'value "horticulture" for :category ' +
          'not present in ["industry", "sector", "peers"]'
        )
      end

      it 'fails if a string parameter is not a string or a symbol' do

        expect {
          Sentofu.company
            .topic_search(keyword: -1)
        }.to raise_error(
          ArgumentError,
          'argument to :keyword not a string (or a symbol)'
        )
      end

      it 'fails if an integer parameter is not an integer' do

        expect {
          Sentofu.company
            .topic_search(keyword: 'blah', size: 'huge')
        }.to raise_error(
          ArgumentError,
          'argument to :size not an integer'
        )
      end
    end

    context 'path deriving' do

      it 'works with single segments' do

        r = Sentofu.company.topic_search(keyword: 'ibm', debug: true)

        expect(r[:path]).to eq(
          'https://apis.sentifi.com/v1/intelligence/topic-search')

      end

      it 'works with multiple segments' do

        r = Sentofu.company.attention.event(debug: true)

        expect(r[:path]).to eq(
          'https://apis.sentifi.com/v1/intelligence' +
          '/attention/event')
      end

      it 'works with multiple segments (2)' do

        r = Sentofu.markets.asset.insight.region(debug: true)

        expect(r[:path]).to eq(
          'https://apis.sentifi.com/v1/intelligence' +
          '/markets/asset/insight/region')
      end

      it 'works with indexed segments' do

        r = Sentofu.company.topic[3].summary_price(debug: true)

        expect(r[:path]).to eq(
          'https://apis.sentifi.com/v1/intelligence' +
          '/topic/3/summary-price')
      end
    end
  end
end

