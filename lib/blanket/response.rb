require 'recursive-open-struct'
require 'json'

module Blanket
  class Response
    attr_reader :payload

    def initialize(json_string)
      json_string ||= "{}"
      @payload = payload_from_json(JSON.parse(json_string))
    end

    def method_missing(method, *args, &block)
      if payload.respond_to? method
        # Defer to RecursiveOpenStruct
        payload.send method
      else
        super
      end
    end

    def respond_to?(method, include_private = false)
      if payload.respond_to? method
        true
      else
        super
      end
    end

    private

    def payload_from_json(json)
      if json
        RecursiveOpenStruct.new json, :recurse_over_arrays => true
      else
        nil
      end
    end
  end
end
