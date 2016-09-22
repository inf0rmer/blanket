require 'spec_helper'
require 'blanket/wrapper'

describe "Blanket::Wrapper" do
  let :api do
    Blanket::wrap("http://api.example.org")
  end

  describe 'Making Requests' do
    it 'resets after performing a request' do
      allow(HTTParty).to receive(:get) { StubbedResponse.new }

      api.users.get()
      api.videos.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/videos", anything())
    end

    it 'allows full paths for uri construction' do
      allow(HTTParty).to receive(:get) { StubbedResponse.new }

      api.get('flexible/path')

      expect(HTTParty).to have_received(:get).with("http://api.example.org/flexible/path", anything())
    end

    it "allows Kernel methods to be used" do
      allow(HTTParty).to receive(:get) { StubbedResponse.new }

      api.get("flexible/send")

      expect(HTTParty).to have_received(:get).
        with("http://api.example.org/flexible/send", anything())
    end

    describe "Response" do
      before :each do
        stub_request(:get, "http://api.example.org/users")
        .to_return(:body => '{"title": "Something"}')
      end

      let :response do
        api.users.get
      end

      it "returns a Blanket::Response instance" do
        expect(response).to be_kind_of(Blanket::Response)
      end
    end

    describe "Exceptions" do
      let :api do
        Blanket::wrap("http://api.example.org")
      end

      describe "400" do
        before :each do
          stub_request(:get, "http://api.example.org/users").to_return(:status => 400, :body => "You've been met with a terrible fate, haven't you?")
        end

        it "raises a Blanket::BadRequestError exception" do
          expect { api.users.get }.to raise_exception(Blanket::BadRequest)
        end
      end

      describe "500" do
        before :each do
          stub_request(:get, "http://api.example.org/users").to_return(:status => 500, :body => "You've been met with a terrible fate, haven't you?")
        end

        it "raises a Blanket::InternalServerError exception" do
          expect { api.users.get }.to raise_exception(Blanket::InternalServerError)
        end
      end

      describe "522, a non registered invalid status code" do
        before :each do
          stub_request(:get, "http://api.example.org/users").to_return(status: 522, body: "You've been met with a terrible fate, haven't you?")
        end

        it "raises a generic instance of Blanket::Exception" do
          expect { api.users.get }.to raise_exception(Blanket::Exception)
        end
      end
    end

    describe 'Resource identification' do
      before do
        allow(HTTParty).to receive(:get) { StubbedResponse.new }
      end

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
      before :each do
        allow(HTTParty).to receive(:get) { StubbedResponse.new }
      end

      it 'allows sending headers in a request' do
        api.users(55).get(headers: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', headers: {"foo" => "bar"})
      end

      it 'allows setting headers globally' do
        api = Blanket::wrap("http://api.example.org", headers: {token: 'my secret token'})
        api.users(55).get()

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', headers: {"token" => "my secret token"})
      end
    end

    describe 'Parameters' do
      before :each do
        allow(HTTParty).to receive(:get) { StubbedResponse.new }
      end

      it 'allows sending parameters in a request' do
        api.users(55).get(params: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', query: {foo: 'bar'})
      end

      it 'allows setting parameters globally' do
        api = Blanket::wrap("http://api.example.org", params: {token: 'my secret token'})
        api.users(55).get(params: {foo: 'bar'})

        expect(HTTParty).to have_received(:get).with('http://api.example.org/users/55', query: {token: 'my secret token', foo: 'bar'})
      end
    end

    describe 'URL Extension' do
      before :each do
        allow(HTTParty).to receive(:get) { StubbedResponse.new }
      end

      it 'allows setting an extension for a request' do
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

    describe 'Body' do
      before :each do
        allow(HTTParty).to receive(:post) { StubbedResponse.new }
      end

      it 'allows setting the body for a request' do
        api = Blanket::wrap("http://api.example.org")
        api.users(55).post(body: { this_key: :this_value }.to_json)

        expect(HTTParty).to have_received(:post).with('http://api.example.org/users/55', body: { this_key: :this_value }.to_json)
      end
    end
  end

  describe '#get' do
    before do
      allow(HTTParty).to receive(:get) { StubbedResponse.new }
    end

    it 'GETs a resource' do
      api.users.get()

      expect(HTTParty).to have_received(:get).with("http://api.example.org/users", anything())
    end
  end

  describe '#post' do
    before do
      allow(HTTParty).to receive(:post) { StubbedResponse.new }
    end

    it 'POSTs a resource' do
      api.users.post()

      expect(HTTParty).to have_received(:post).with("http://api.example.org/users", anything())
    end
  end

  describe '#put' do
    before do
      allow(HTTParty).to receive(:put) { StubbedResponse.new }
    end

    it 'PUTs a resource' do
      api.users.put()

      expect(HTTParty).to have_received(:put).with("http://api.example.org/users", anything())
    end
  end

  describe '#patch' do
    before do
      allow(HTTParty).to receive(:patch) { StubbedResponse.new }
    end

    it 'PATCHes a resource' do
      api.users.patch()

      expect(HTTParty).to have_received(:patch).with("http://api.example.org/users", anything())
    end
  end

  describe '#delete' do
    before do
      allow(HTTParty).to receive(:delete) { StubbedResponse.new }
    end

    it 'DELETEs a resource' do
      api.users.delete()

      expect(HTTParty).to have_received(:delete).with("http://api.example.org/users", anything())
    end
  end
end
