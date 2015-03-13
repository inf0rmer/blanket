require 'spec_helper'
require 'blanket/response'

describe Blanket::Response do
  describe "Dynamic attribute accessors" do
    context "With single objects" do
      let :payload do
        {
          title: "Something",
          desc: {
            someKey: "someValue",
            anotherKey:"value"
          },
          main_item: {
            values:[
              { quantity: 1 },
              { quantity: 2 },
              { quantity: 3 }
            ]
          }
        }.to_json
      end

      let :response do
        Blanket::Response.new(payload)
      end

      it "can access the payload json" do
        expect(response.payload_json).to eq payload
      end

      it "can access a surface property from a json string as a method" do
        expect(response.title).to eq("Something")
      end

      it "can access a deep property from a json string as a method" do
        expect(response.desc.someKey).to eq("someValue")
      end

      it "can access a deep property in an array from a json string as a method" do
        expect(response.main_item.values[0].quantity).to eq(1)
      end
    end

    context "With an array of objects" do
      let(:title1)  { "Something" }
      let(:title2)  { "Something else" }
      let(:payload) { [{ title: title1 }, { title: title2 }].to_json }

      let :response do
        Blanket::Response.new(payload)
      end

      let :titles do
        response.map(&:title)
      end

      it "can access methods from each item" do
        expect(titles).to match_array([title1, title2])
      end

      context "With an array containing a single object" do
        let(:payload) { [{ title: title1 }].to_json }
        let :response do
          Blanket::Response.new(payload)
        end

        it "keeps the payload as an array" do
          expect(response.first).to be
        end
      end
    end
  end
end
