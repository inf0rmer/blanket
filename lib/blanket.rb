require_relative "blanket/version"
require_relative "blanket/response"
require_relative "blanket/exception"
require_relative "blanket/wrapper"
require 'httparty'

# The main Blanket module
module Blanket
  # Wraps an API using Blanket::Wrapper
  def self.wrap(*args)
    Wrapper.new *args
  end
end
