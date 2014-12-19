# Blanket

A dead simple API wrapper.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blanket'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blanket

## Usage

```ruby
github = blanket("https://api.github.com")

# Get some user's info
github.users('inf0rmer').get
# => {
#  "login": "inf0rmer",
#  "id": 290137,
#  ...
# }

# Get a user's repos
github.users('inf0rmer').repos().get
# => {
#  "id": 20000073,
#  "name": "BAPersistentOperationQueue",
#  ...
# }
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/blanket/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
