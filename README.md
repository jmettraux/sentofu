
# sentofu

A Ruby client to some of the 1.0.0 Sentifi.com APIs.

## proxy

Sentofu follows the vanilla `ENV['http_proxy']` Ruby proxy setting.

It also accepts a dedicated `ENV['sentofu_http_proxy']` environment variable.

In Ruby:
```ruby
ENV['sentofu_http_proxy'] = 'http://proxy.example.com'
  # or
ENV['sentofu_http_proxy'] = 'http://proxy.example.com:8080'
  # or
ENV['sentofu_http_proxy'] = 'http://user:pass@proxy.example.com'
  # or
ENV['sentofu_http_proxy'] = 'http://user:pass@proxy.example.com:8080'
```

From the command line:
```
$ http_proxy = 'http://user:pass@proxy.example.com'
$ sentofu_http_proxy = 'http://user:pass@proxy.example.com'
```

## license

MIT, see [LICENSE.txt](LICENSE.txt)

