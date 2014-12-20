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
        payload.send method, *args, &block
      else
        super
      end
    end

    private

    def payload_from_json(json)
      if json
        parsed = [json].flatten.map do |item|
          RecursiveOpenStruct.new item, :recurse_over_arrays => true
        end

        (parsed.count == 1) ? parsed.first : parsed
      else
        nil
      end
    end
  end
end
