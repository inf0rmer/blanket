require 'spec_helper'

describe Blanket do
  describe '.wrap' do
    it "creates a new Blanket::Wrapper instance" do
      expect(Blanket.wrap("a_url")).to be_kind_of(Blanket::Wrapper)
    end
  end
end
