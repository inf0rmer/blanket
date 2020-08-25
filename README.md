# Blanket
[![Build Status](https://travis-ci.org/inf0rmer/blanket.svg?branch=master)](https://travis-ci.org/inf0rmer/blanket)
[![Coverage Status](https://img.shields.io/coveralls/inf0rmer/blanket.svg)](https://coveralls.io/r/inf0rmer/blanket?branch=master)
[![Code Climate](https://codeclimate.com/github/inf0rmer/blanket/badges/gpa.svg)](https://codeclimate.com/github/inf0rmer/blanket)
[![Inline docs](http://inch-ci.org/github/inf0rmer/blanket.svg?branch=master)](http://inch-ci.org/github/inf0rmer/blanket)


A dead simple API wrapper.

**Table of Contents**

- [Installation](#installation)
- [Usage](#usage)
	- [Quick demo](#quick-demo)
	- [How it works](#how-it-works)
	- [Responses](#responses)
	- [Request Parameters](#request-parameters)
	- [Headers](#headers)
	- [Extensions](#extensions)
	- [Handling Exceptions](#handling-exceptions)
- [Contributing](#contributing)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blanket_wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blanket_wrapper

## Usage

### Quick demo

```ruby
require 'blanket'

github = Blanket.wrap("https://api.github.com")

# Get some user's info
user = github.users('inf0rmer').get
user.login
# => "inf0rmer"

# Get a user's repos
github.users('inf0rmer').repos.get
# => [{
#  "id": 20000073,
#  "name": "BAPersistentOperationQueue",
#  ...
# }]
```

### How it works
Blanket uses some metaprogramming black magic to wrap an API. Everytime you call a method on a wrapped API, Blanket appends it as a part of the final URL:

```ruby
github = Blanket.wrap("https://api.github.com")
github.users('inf0rmer').repos.get
```

Here's how the final URL is built, the step by step:

```ruby
github = Blanket.wrap("https://api.github.com")
# => "https://api.github.com"

github.users
# => "https://api.github.com/users"

github.users('inf0rmer')
# => "https://api.github.com/users/inf0rmer"

github.users('inf0rmer').repos
# => "https://api.github.com/users/inf0rmer/repos"
```

The final `get` method performs a GET HTTP request. You can also use it to append a final part to your request, so you can write something like:

As this magic works using `method_missing`, you can `send` slashed uri parts to the wrapper and it will play nicely. This is especially usefull when APIs give you URLs:
```ruby
github.get('users/inf0rmer/repos')
# or, if you don't wnat to perform the request yet, or have to append more parts to the uri
github.send('users/inf0rmer').repos#.get
```

```ruby
github = Blanket.wrap("https://api.github.com")
github.users.get('inf0rmer')
# => "https://api.github.com/users/inf0rmer"
```

### Responses
At the moment Blanket only accepts JSON responses. Every request returns a `Blanket::Response` instance, which parses the JSON internally and lets you access keys using dot syntax:

```ruby
user = github.users('inf0rmer').get

user.login
# => "inf0rmer"

user.url
# => "https://api.github.com/users/inf0rmer"

# It even works on nested keys
repo = github.repos('inf0rmer').get('blanket')

repo.owner.login
# => "inf0rmer"
```

If the response is an array, all `Enumerable` methods work as expected:

```ruby
repos = github.users('inf0rmer').repos.get

repos.map(&:name)
# => ["analytics-ios", "aztec", "fusebox", ...]
```

### Request Body
You can make requests with body using the `body` option:

```ruby
api = Blanket::wrap("http://api.example.org")
api.messages.post(body: 'Hello')
```

### Request Parameters
Blanket supports appending parameters to your requests:

```ruby
api.users(55).get(params: {foo: 'bar'})
# => "http://api.example.org/users/55?foo=bar"
```

You can also set default params for all your requests on initialization:

```ruby
api = Blanket::wrap("http://api.example.org", params: {access_token: 'my secret token'})
```

### Headers
HTTP Headers are always useful when accessing an API, so Blanket makes it easy for you to specify them, either globally or on a per-request basis:

```ruby
# All requests will carry the `token` header
api = Blanket::wrap("http://api.example.org", headers: {token: 'my secret token'})

# This single request will carry the `foo` header
api.users(55).get(headers: {foo: 'bar'})
```

### Extensions
Some APIs require you to append an extension to your requests, such as `.json` or `.xml`. Blanket supports this use case, letting you define an extension for all your requests or override it for a single one:

```ruby
# All request URLs are suffixed with ".json"
api = Blanket::wrap("http://api.example.org", extension: :json)

# Requests to "users_endpoint" are suffixed with ".xml" instead
users_endpoint = api.users(55)
users_endpoint.extension = :xml
```

### Timeouts
Some applications may require setting a timeout for your requests to ensure the request finishes within a given time
or else an error will be raised. Simply pass your desired timeout to the .wrap options

```ruby
# All requests will raise an exception if they last longer than 15s
api = Blanket.wrap("http://api.example.org", timeout: 15)

begin
  api.users(55).get
rescue Timeout::Error => e
  puts "Getting user 55 took too long!"
end

# An endpoint being built can override the timeout
users_endpoint = api.user
users_endpoint.timeout = 30

# Individual request actions can override the timeout
users_endpoint.get(55, timeout: 10)
```

### Handling Exceptions

Blanket will raise exceptions for HTTP errors encountered while making requests. Exception subclasses are raised for well known errors (404, 500, etc.) but for other status codes a default `Blanket::Exception` will be raised instead.

```ruby
begin
  api.thingamajig.get
rescue Blanket::ResourceNotFound => e
  e.code
  # => 404

  e.message
  # => "404: Resource Not Found"

  # The HTTP body, ie. the error message sent by the server
  e.body
  # => "Could not find this resource!"
end
```

## Contributing

1. Fork it ( https://github.com/inf0rmer/blanket/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
