
require 'pp'

require 'sentofu'


Sentofu.init
Sentofu.ssl_verify_mode = OpenSSL::SSL::VERIFY_NONE # :-(

pp Sentofu.markets.summary
pp Sentofu.markets.summary['data']

