require 'json'
module Blanket

  # The Response class wraps HTTP responses
  class Response
    # Attribute reader for the original JSON payload string and JSON payload
    attr_reader :payload_json

    # A Blanket HTTP response wrapper.
    # @param [String] json_string A string containing data in the JSON format
    # @return [Blanket::Response] The wrapped Response object
    def initialize(json_string)
      @payload_json = json_string || "{}"
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

    def payload
      @payload ||= JSON.parse(payload_json, object_class: OpenStruct)
    end
  end
end
