require "../spec_helper"

describe TranslatableTestObject do
  describe "#first_name" do
    it "returns the translated value" do
      test_object.first_name.should eq("First name")
    end
  end

  describe "#name_with_inferrence" do
    it "infers the key from the class name" do
      test_object.name_with_inferrence.should eq("Inferred name")
    end
  end
end

describe TranslatableTestObjectWithRosettaPrefix do
  describe "#name" do
    it "uses the defined prefix" do
      test_object_with_prefix.name.should eq("Fixed prefix")
    end
  end
end

# Test objects
class TranslatableTestObject
  include Rosetta::Translatable

  def first_name
    t rosetta("user.first_name")
  end

  def name_with_inferrence
    t rosetta(".inferred_name")
  end
end

class TranslatableTestObjectWithRosettaPrefix
  include Rosetta::Translatable

  ROSETTA_PREFIX = "fixed.prefix"

  def name
    t rosetta(".name")
  end
end

private def test_object
  TranslatableTestObject.new
end

private def test_object_with_prefix
  TranslatableTestObjectWithRosettaPrefix.new
end
