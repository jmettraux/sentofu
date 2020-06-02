
#
# Specifying sentifi
#
# Fri May 17 09:53:37 JST 2019
#

require 'pp'
#require 'ostruct'

require 'sentofu'
Sentofu.init
Sentofu.ssl_verify_mode = OpenSSL::SSL::VERIFY_NONE # :-(


module Helpers

  def jruby?; !! RUBY_PLATFORM.match(/java/); end
  def windows?; Gem.win_platform?; end
end # Helpers


RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end

