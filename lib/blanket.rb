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

    # RESTful actions
    [:get, :post, :put, :patch, :delete].each do |action|
      define_method(action) do |id=nil, options={}|
        request(action, id, options)
      end
    end

    def method_missing(method, *args, &block)
      Blanket.new uri_from_parts([method, args.first]), {
        headers: @headers,
        extension: @extension
      }
    end

    private

    def request(method, id=nil, options={})
      if id.is_a? Hash
        options = id
        id = nil
      end

      headers = merged_headers(options[:headers])
      uri = uri_from_parts([id])

      if @extension
        uri = "#{uri}.#{extension}"
      end

      response = HTTParty.send(method, uri, {
        query:   options[:params],
        headers: headers
      }.reject { |k, v| v.nil? || v.empty? })

      body = (response.respond_to? :body) ? response.body : nil

      (body.is_a? Array) ? body.map(Response.new) : Response.new(body)
    end

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
