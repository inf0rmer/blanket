require 'spec_helper'

describe Blanket do
  describe '#get' do
    let :api do
      Blanket::wrap("http://api.example.org")
    end

    before :each do
      allow(HTTParty).to receive(:get)
    end

    it 'GETs a simple resource' do
      api.users.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/users")
    end

    it 'resets after performing a request' do
      api.users.get()
      api.videos.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/videos")
    end
  end
end
