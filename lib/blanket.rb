require "blanket/version"
require "blanket/response"
require 'httparty'

module Blanket
  def self.wrap(base_uri)
    Blanket.new base_uri
  end

  class Blanket
    attr_accessor :headers

    def initialize(base_uri)
      @base_uri = base_uri
      @uri_parts = []
      @headers = {}
    end

    def get(id=nil, options={})
      if id.is_a? Hash
        options = id
        id = nil
      end

      @uri_parts << id

      headers = merged_headers(options[:headers])

      response = HTTParty.get(uri_from_parts, options[:params], headers)

      @uri_parts = []

      Response.new (response.respond_to? :body) ? response.body : nil
    end

    def respond_to?(method, include_private = false)
      true
    end

    def method_missing(method, *args, &block)
      @uri_parts << method << args.first
      self
    end

    private

    def merged_headers(headers)
      headers = @headers.merge(headers != nil ? headers : {})
    end

    def uri_from_parts
      @uri_parts.clone
        .compact
        .inject(@base_uri.clone) { |memo, part| memo << "/#{part}" }
    end
  end
end
