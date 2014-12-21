require "blanket/version"
require "blanket/response"
require "blanket/wrapper"
require 'httparty'

module Blanket
  # Wraps an API using Blanket::Wrapper
  def self.wrap(*args)
    Wrapper.new *args
  end
end
