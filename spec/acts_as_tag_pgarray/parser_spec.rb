require "spec_helper"

describe ActsAsTaggableArrayOn::Parser do
  let(:parser) { ActsAsTaggableArrayOn.parser }

  describe "#parse" do
    it "return unprocessed tags if array" do
      tags = %w[red green]
      expect(parser.parse(tags)).to eq tags
    end

    it "return parsed tags if comma separated string" do
      tags = "red,green"
      expect(parser.parse(tags)).to eq %w[red green]
    end

    it "return parsed tags if comma separated string including white spaces" do
      tags = "red   , gre  en"
      expect(parser.parse(tags)).to eq ["red", "gre  en"]
    end
  end
end
