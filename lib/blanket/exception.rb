module Blanket

  STATUSES = {100 => 'Continue',
              101 => 'Switching Protocols',
              102 => 'Processing', #WebDAV

              200 => 'OK',
              201 => 'Created',
              202 => 'Accepted',
              203 => 'Non-Authoritative Information', # http/1.1
              204 => 'No Content',
              205 => 'Reset Content',
              206 => 'Partial Content',
              207 => 'Multi-Status', #WebDAV

              300 => 'Multiple Choices',
              301 => 'Moved Permanently',
              302 => 'Found',
              303 => 'See Other', # http/1.1
              304 => 'Not Modified',
              305 => 'Use Proxy', # http/1.1
              306 => 'Switch Proxy', # no longer used
              307 => 'Temporary Redirect', # http/1.1

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

  class Exception < RuntimeError
    attr_writer :message
    attr_reader :response

    def initialize(response = nil)
      @response = response
    end

    def body
      @response.body.to_s if @response
    end

    def code
      @response.code.to_i if @response
    end

    def message
      @message || self.class.name
    end

  end

  STATUSES.each_pair do |code, message|
    klass = Class.new(Exception) do
      send(:define_method, :message) {"#{code ? "#{code} " : ''}#{message}"}
    end

    const_set message.delete(' \-\''), klass
  end
end
