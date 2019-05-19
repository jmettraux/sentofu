
#
# Specifying sentofu
#
# Sun May 19 07:11:11 JST 2019
#

require 'spec_helper'


describe Sentofu::Api do

  describe 'fetching' do

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
end

