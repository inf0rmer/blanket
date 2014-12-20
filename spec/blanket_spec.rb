require 'spec_helper'

describe Blanket do
  let :api do
    Blanket::wrap("http://api.example.org")
  end

  describe 'Making Requests' do
    before :each do
      allow(HTTParty).to receive(:get)
    end

    it 'resets after performing a request' do
      api.users.get()
      api.videos.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/videos", anything())
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

          expect(HTTParty).to have_received(:get).with("http://api.example.org/users/55", anything())
        end

        it 'only allows one identifier per resource' do
          api.users(55, 37).get()

          expect(HTTParty).not_to have_received(:get).with("http://api.example.org/users/55/37", anything())
        end
      end

      context 'When using #get' do
        it 'allows identifying the last resource' do
          api.users(55).videos.get(15)

          expect(HTTParty).to have_received(:get).with("http://api.example.org/users/55/videos/15", anything())
        end
      end
    end

    describe 'Headers' do
      it 'allows sending headers in a request' do
        api.users(55).get(headers: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', headers: {foo: 'bar'})
      end

      it 'allows setting headers globally' do
        api = Blanket::wrap("http://api.example.org", headers: {token: 'my secret token'})
        api.users(55).get()

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', headers: {token: 'my secret token'})
      end
    end

    describe 'Parameters' do
      it 'allows sending parameters in a request' do
        api.users(55).get(params: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', query: {foo: 'bar'})
      end
    end

    describe 'URL Extension' do
      it 'allows setting an extension for a request', :wip => true do
        users_endpoint = api.users(55)
        users_endpoint.extension = :json
        users_endpoint.get

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55.json', anything())
      end

      it 'allows setting an extension globally' do
        api = Blanket::wrap("http://api.example.org", extension: :xml)
        api.users(55).get

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55.xml', anything())
      end
    end
  end

  describe '#get' do
    before :each do
      allow(HTTParty).to receive(:get)
    end

    it 'GETs a resource' do
      api.users.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/users", anything())
    end
  end

  describe '#post' do
    before :each do
      allow(HTTParty).to receive(:post)
    end

    it 'POSTs a resource' do
      api.users.post()

      expect(HTTParty).to have_received(:post).with("http://api.example.org/users", anything())
    end
  end

  describe '#put' do
    before :each do
      allow(HTTParty).to receive(:put)
    end

    it 'PUTs a resource' do
      api.users.put()

      expect(HTTParty).to have_received(:put).with("http://api.example.org/users", anything())
    end
  end

  describe '#patch' do
    before :each do
      allow(HTTParty).to receive(:patch)
    end

    it 'PATCHes a resource' do
      api.users.patch()

      expect(HTTParty).to have_received(:patch).with("http://api.example.org/users", anything())
    end
  end

  describe '#delete' do
    before :each do
      allow(HTTParty).to receive(:delete)
    end

    it 'DELETEs a resource' do
      api.users.delete()

      expect(HTTParty).to have_received(:delete).with("http://api.example.org/users", anything())
    end
  end
end
