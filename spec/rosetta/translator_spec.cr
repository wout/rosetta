require "../spec_helper"

class TranslatableTestObject
  include Rosetta::Translator

  def name
    look_up("user.first_name")[Rosetta.locale]
  end
end

private def test_object
  TranslatableTestObject.new
end

describe Rosetta::Translator do
  describe "#name" do
    it "returns the translated value" do
      test_object.name.should eq("First name")
    end
  end
end
