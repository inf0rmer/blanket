require "blanket/version"
require "blanket/response"
require 'httparty'

module Blanket
  def self.wrap(*args)
    Blanket.new *args
  end

  class Blanket
    attr_accessor :headers
    attr_accessor :extension

    def initialize(base_uri, options={})
      @base_uri = base_uri
      @uri_parts = []
      @headers = (options[:headers].nil?) ? {} : options[:headers]
      @extension = options[:extension]
    end

    def get(id=nil, options={})
      if id.is_a? Hash
        options = id
        id = nil
      end

      headers = merged_headers(options[:headers])
      uri = uri_from_parts([id])

      if @extension
        uri = "#{uri}.#{extension}"
      end

      response = HTTParty.get(uri, {
        query:   options[:params],
        headers: headers
      }.reject { |k, v| v.nil? || v.empty? })

      Response.new (response.respond_to? :body) ? response.body : nil
    end

    def method_missing(method, *args, &block)
      Blanket.new uri_from_parts([method, args.first]), {
        headers: @headers,
        extension: @extension
      }
    end

    private

    def merged_headers(headers)
      headers = @headers.merge(headers != nil ? headers : {})
    end

    def uri_from_parts(parts)
      parts
        .clone
        .compact
        .inject(@base_uri.clone) { |memo, part| memo << "/#{part}" }
    end
  end
end
