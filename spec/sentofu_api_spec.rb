
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
        Sentofu.company.topic_search
      }.to raise_error(
        ArgumentError, 'missing query parameter :keyword'
      )
    end
  end
end

