require 'spec_helper'
require 'blanket/exception'

describe Blanket::Exception do
  describe "#message" do
    context "When a message is not set" do
      let :e do
        Blanket::Exception.new
      end

      it "returns its Class name" do
        expect(e.message).to eq("Blanket::Exception")
      end
    end

    context "When a message is set" do
      let :message do
        "A custom exception message"
      end

      let :e do
        e = Blanket::Exception.new
        e.message = message
        e
      end

      it "returns the custom message" do
        expect(e.message).to eq(message)
      end
    end
  end

  describe "#response" do
    let :response do
      double("HTTP Response", code: 500)
    end

    let :e do
      Blanket::InternalServerError.new(response)
    end

    it "allows access to the HTTP status code" do
      expect(e.response).to eq(response)
    end
  end

  describe "#code" do
    let :response do
      double("HTTP Response", code: 500)
    end

    let :e do
      Blanket::InternalServerError.new(response)
    end

    it "allows access to the HTTP status code" do
      expect(e.code).to eq(response.code)
    end
  end

  describe "#body" do
    let :body do
      "Internal Server Error"
    end

    let :response do
      double("HTTP Response", code: 500, body: body)
    end

    let :e do
      Blanket::InternalServerError.new(response)
    end

    it "allows access to the HTTP response body" do
      expect(e.body).to eq(body)
    end
  end
end

describe Blanket::ResourceNotFound do
  let :e do
    e = Blanket::ResourceNotFound.new
  end

  it "inherits from Blanket::Exception" do
    expect(e).to be_kind_of(Blanket::Exception)
  end

  it "has a '404 Resource Not Found' message" do
    expect(e.message).to eq("404 Resource Not Found")
  end
end

describe Blanket::InternalServerError do
  let :e do
    e = Blanket::InternalServerError.new
  end

  it "inherits from Blanket::Exception" do
    expect(e).to be_kind_of(Blanket::Exception)
  end

  it "has a '500 Internal Server Error' message" do
    expect(e.message).to eq("500 Internal Server Error")
  end
end
