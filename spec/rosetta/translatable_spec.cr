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

  describe "#welcome_message_with_arguments" do
    it "accepts interpolation messages" do
      test_object.welcome_message_with_arguments
        .should eq("Hi First name, have a fabulous whenever day!")
    end
  end

  describe "#welcome_message_with_hash" do
    it "accepts interpolation messages" do
      test_object.welcome_message_with_hash
        .should eq("Hi Willy, have a fabulous Wonka day!")
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
    r("user.first_name").to_s
  end

  def name_with_inferrence
    r(".inferred_name").to_s
  end

  def welcome_message_with_arguments
    r("interpolatable.string").t(
      name: "#{first_name}",
      day_name: "whenever day"
    )
  end

  def welcome_message_with_hash
    interpolation_values = {:name => "Willy", "day_name" => "Wonka day"}

    r("interpolatable.string").t_hash(interpolation_values)
  end
end

class TranslatableTestObjectWithRosettaPrefix
  include Rosetta::Translatable

  ROSETTA_PREFIX = "fixed.prefix"

  def name
    r(".name").to_s
  end
end

# Helpers
private def test_object
  TranslatableTestObject.new
end

private def test_object_with_prefix
  TranslatableTestObjectWithRosettaPrefix.new
end
