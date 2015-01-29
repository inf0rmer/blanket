require 'spec_helper'
require 'blanket/response'

describe "Blanket::Response" do
  describe "Dynamic attribute accessors" do
    context "With single objects" do
      let :response do
        Blanket::Response.new('{"title": "Something", "desc":{"someKey":"someValue","anotherKey":"value"},"main_item":{"values":[{"quantity": 1}, {"quantity": 2}, {"quantity": 3}]}}')
      end

      it "can access a surface property from a json string as a method" do
        expect(response.first.title).to eq("Something")
      end

      it "can access a deep property from a json string as a method" do
        expect(response.first.desc.someKey).to eq("someValue")
      end

      it "can access a deep property in an array from a json string as a method" do
        expect(response.first.main_item.values[0].quantity).to eq(1)
      end
    end

    context "With an array of objects" do
      let :response do
        Blanket::Response.new('[{"title": "Something"}, {"title": "Something else"}]')
      end

      let :titles do
        response.map(&:title)
      end

      it "can access methods from each item" do
        expect(titles).to match_array(["Something", "Something else"])
      end
    end
  end
end
