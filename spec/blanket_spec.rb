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

      expect(HTTParty).to have_received(:get).with("http://api.example.org/users", nil, nil)
    end

    it 'resets after performing a request' do
      api.users.get()
      api.videos.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/videos", nil, nil)
    end

    describe "Response" do
      before :each do
        stub_request(:get, "http://api.example.org/users").to_return(:body => '{"title": "Something"}')
      end

      let :response do
        api.users.get()
      end

      it "returns a Blanket::Response instance" do
        expect(response).to be_kind_of(Blanket::Response)
      end
    end

    describe 'Resource identification' do
      context 'When using a resource method' do
        it 'allows identifying a resource' do
          api.users(55).get()

          expect(HTTParty).to have_received(:get).with("http://api.example.org/users/55", nil, nil)
        end

        it 'only allows one identifier per resource' do
          api.users(55, 37).get()

          expect(HTTParty).not_to have_received(:get).with("http://api.example.org/users/55/37", nil, nil)
        end
      end

      context 'When using #get' do
        it 'allows identifying the last resource' do
          api.users(55).videos.get(15)

          expect(HTTParty).to have_received(:get).with("http://api.example.org/users/55/videos/15", nil, nil)
        end
      end
    end

    describe 'Headers' do
      it 'allows sending headers in a request' do
        api.users(55).get(headers: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', nil, {foo: 'bar'})
      end
    end

    describe 'Parameters' do
      it 'allows sending parameters in a request' do
        api.users(55).get(params: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', {foo: 'bar'}, nil)
      end
    end
  end
end
