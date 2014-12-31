module Blanket
  # The Wrapper class wraps an API
  class Wrapper
    class << self
      private
      # @macro [attach] REST action
      #   @method $1()
      #   Performs a $1 request on the wrapped URL
      #   @param [String, Symbol, Numeric] id The resource identifier to attach to the last part of the request
      #   @param [Hash] options An options hash with values for :headers, :extension and :params
      #   @return [Blanket::Response, Array] A wrapped Blanket::Response or an Array
      def add_action(action)
        define_method(action) do |id=nil, options={}|
          request(action, id, options)
        end
      end
    end

    # Attribute accessor for HTTP Headers that
    # should be applied to all requests
    attr_accessor :headers

    # Attribute accessor for file extension that
    # should be appended to all requests
    attr_accessor :extension

    add_action :get
    add_action :post
    add_action :put
    add_action :patch
    add_action :delete

    # Wraps the base URL for an API
    # @param [String, Symbol] base_uri The root URL of the API you wish to wrap.
    # @param [Hash] options An options hash with global values for :headers and :extension
    # @return [Blanket] The Blanket object wrapping the API
    def initialize(base_uri, options={})
      @base_uri = base_uri
      @uri_parts = []
      @headers = options[:headers] || {}
      @extension = options[:extension]
    end

    private

    def method_missing(method, *args, &block)
      Wrapper.new uri_from_parts([method, args.first]), {
        headers: @headers,
        extension: @extension
      }
    end

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

      if response.code <= 400
        body = (response.respond_to? :body) ? response.body : nil
        (body.is_a? Array) ? body.map(Response.new) : Response.new(body)
      else
        raise Blanket::Exceptions::EXCEPTIONS_MAP[response.code].new(response)
      end
    end

    def merged_headers(headers)
      @headers.merge(headers || {})
    end

    def uri_from_parts(parts)
      ([@base_uri] + parts).compact.join('/')
    end
  end
end
