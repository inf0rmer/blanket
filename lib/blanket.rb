require "blanket/version"
require 'httparty'

module Blanket
  def self.wrap(base_uri)
    Blanket.new base_uri
  end

  class Blanket
    def initialize(base_uri)
      @base_uri = base_uri
      @uri_parts = []
    end

    def get
      HTTParty.get uri_from_parts(@base_uri.clone, @uri_parts.clone)
      @uri_parts = []
    end

    def respond_to?(method, include_private = false)
      true
    end

    def method_missing(method, *args, &block)
      @uri_parts << method
      self
    end

    private

    def uri_from_parts(base_uri, parts)
      parts.inject(base_uri) do |memo, part|
        memo << "/#{part}"
      end
    end
  end
end
