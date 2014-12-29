lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'coveralls'
Coveralls.wear!

class StubbedResponse
  def code
    200
  end
end

require 'pry'
require 'webmock/rspec'
require 'blanket'
