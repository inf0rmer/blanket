module Blanket

  # A Map of "error" HTTP status codes and their names
  STATUSES = {
              400 => 'Bad Request',
              401 => 'Unauthorized',
              402 => 'Payment Required',
              403 => 'Forbidden',
              404 => 'Resource Not Found',
              405 => 'Method Not Allowed',
              406 => 'Not Acceptable',
              407 => 'Proxy Authentication Required',
              408 => 'Request Timeout',
              409 => 'Conflict',
              410 => 'Gone',
              411 => 'Length Required',
              412 => 'Precondition Failed',
              413 => 'Request Entity Too Large',
              414 => 'Request-URI Too Long',
              415 => 'Unsupported Media Type',
              416 => 'Requested Range Not Satisfiable',
              417 => 'Expectation Failed',
              418 => 'I\'m A Teapot', #RFC2324
              421 => 'Too Many Connections From This IP',
              422 => 'Unprocessable Entity', #WebDAV
              423 => 'Locked', #WebDAV
              424 => 'Failed Dependency', #WebDAV
              425 => 'Unordered Collection', #WebDAV
              426 => 'Upgrade Required',
              428 => 'Precondition Required', #RFC6585
              429 => 'Too Many Requests', #RFC6585
              431 => 'Request Header Fields Too Large', #RFC6585
              449 => 'Retry With', #Microsoft
              450 => 'Blocked By Windows Parental Controls', #Microsoft

              500 => 'Internal Server Error',
              501 => 'Not Implemented',
              502 => 'Bad Gateway',
              503 => 'Service Unavailable',
              504 => 'Gateway Timeout',
              505 => 'HTTP Version Not Supported',
              506 => 'Variant Also Negotiates',
              507 => 'Insufficient Storage', #WebDAV
              509 => 'Bandwidth Limit Exceeded', #Apache
              510 => 'Not Extended',
              511 => 'Network Authentication Required', # RFC6585
  }

  # The base class for all Blanket Exceptions
  class Exception < RuntimeError
    # Attribute writer for the Exception message
    attr_writer :message
    # Attribute reader for the Exception http response
    attr_reader :response

    # Creates a new exception
    # @param [HTTParty::Response] response the HTTP Response
    # @return [Blanket::Exception] The Blanket Exception object
    def initialize(response = nil)
      @response = response
    end

    # Returns the HTTP response body
    def body
      @response.body.to_s if @response
    end

    # Returns the HTTP status code
    def code
      @response.code.to_i if @response
    end

    # Returns a formatted error message
    def message
      @message || self.class.name
    end

    # Returns a stringified error message
    def inspect
      "#{message}: #{body}"
    end

    # Returns a stringified error message
    def to_s
      inspect
    end
  end

  # We will a create an exception for each status code, see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  module Exceptions
    # Map http status codes to the corresponding exception class
    EXCEPTIONS_MAP = {}
  end

  STATUSES.each_pair do |code, message|
    klass = Class.new(Exception) do
      define_method :message do
        "#{code} #{message}"
      end
    end

    klass_constant = const_set message.delete(' \-\''), klass
    Exceptions::EXCEPTIONS_MAP[code] = klass_constant
  end
end
