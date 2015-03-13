require 'recursive-open-struct'
require 'json'
module Blanket

  # The Response class wraps HTTP responses
  class Response
    # Attribute reader for the original JSON payload string and JSON payload
    attr_reader :payload, :payload_json

    # A Blanket HTTP response wrapper.
    # @param [String] json_string A string containing data in the JSON format
    # @return [Blanket::Response] The wrapped Response object
    def initialize(json_string)
      json_string ||= "{}"
      json = JSON.parse(json_string)
      @payload = payload_from_json(json)
      @payload_json = json.to_json
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

      (json.is_a? Array) ? parsed : parsed.first
    end

  end
end
