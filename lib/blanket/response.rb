require 'recursive-open-struct'
require 'json'

module Blanket

  # The Response class wraps HTTP responses
  class Response
    # Attribute reader for the original JSON payload string
    attr_reader :payload

    # A Blanket HTTP response wrapper.
    # @param [String] json_string A string containing data in the JSON format
    # @return [Blanket::Response] The wrapped Response object
    def initialize(json_string)
      json_string ||= "{}"
      @payload = payload_from_json(JSON.parse(json_string))
    end

    private

    # Allows accessing the payload's JSON keys through methods.
    def method_missing(method, *args, &block)
      if payload.respond_to? method
        payload.public_send method, *args, &block
      else
        super
      end
    end

    def payload_from_json(json)
      parsed = [json].flatten.map do |item|
        RecursiveOpenStruct.new item, recurse_over_arrays: true
      end

      (parsed.count == 1) ? parsed.first : parsed
    end

  end
end
