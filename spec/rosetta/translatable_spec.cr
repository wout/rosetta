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

  describe "#interpolated_message_with_arguments" do
    it "accepts interpolation arguments" do
      test_object.interpolated_message_with_arguments
        .should eq("Hi First name, have a fabulous whenever day!")
    end
  end

  describe "#interpolated_message_with_hash" do
    it "accepts interpolation arguments" do
      test_object.interpolated_message_with_hash
        .should eq("Hi Willy, have a fabulous Wonka day!")
    end
  end

  describe "#pluralized_message_with_arguments" do
    it "pluralizes according to the given count" do
      test_object.pluralized_message_with_arguments(1)
        .should eq("Hi Jeremy, you've got one message.")
      test_object.pluralized_message_with_arguments(23)
        .should eq("Hi Jeremy, you've got 23 messages.")
    end
  end

  describe "#pluralized_message_with_hash" do
    it "pluralizes according to the given count" do
      test_object.pluralized_message_with_hash(1)
        .should eq("Hi Jeremy, you've got one message.")
      test_object.pluralized_message_with_hash(23)
        .should eq("Hi Jeremy, you've got 23 messages.")
    end

    it "raises an error if no count is given" do
      expect_raises(Rosetta::InterpolationArgumentException) do
        test_object.pluralized_message_with_hash(nil)
      end
    end
  end

  describe "#pluralized_message_with_time_and_hash" do
    it "pluralizes according to the given count" do
      test_object.pluralized_message_with_time_and_hash(1)
        .should eq("You have an appointment on Friday at 09:21.")
      test_object.pluralized_message_with_time_and_hash(11)
        .should eq("You have 11 appointments on Friday at 09:21.")
    end
  end

  describe "#pluralized_message_with_date_and_hash" do
    it "pluralizes according to the given count" do
      test_object.pluralized_message_with_date_and_hash(1)
        .should eq("You have an appointment on Friday at 00:00.")
      test_object.pluralized_message_with_date_and_hash(11)
        .should eq("You have 11 appointments on Friday at 00:00.")
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
    r("user.first_name").t
  end

  def name_with_inferrence
    r(".inferred_name").t
  end

  def interpolated_message_with_arguments
    r("interpolatable.string")
      .t(name: "#{first_name}", day_name: "whenever day")
  end

  def interpolated_message_with_hash
    r("interpolatable.string")
      .t_hash({:name => "Willy", "day_name" => "Wonka day"})
  end

  def pluralized_message_with_arguments(count)
    r("pluralizable.string").t(name: "Jeremy", count: count)
  end

  def pluralized_message_with_hash(count)
    r("pluralizable.string").t_hash({"name" => "Jeremy", "count" => count})
  end

  def pluralized_message_with_time_and_hash(count)
    r("pluralizable.localizable.string").t_hash({
      "count" => count,
      "time"  => Time.local(2021, 9, 24, 9, 21, 24),
    })
  end

  def pluralized_message_with_date_and_hash(count)
    r("pluralizable.localizable.string").t_hash({
      "count" => count,
      "time"  => {2021, 9, 24},
    })
  end
end

class TranslatableTestObjectWithRosettaPrefix
  include Rosetta::Translatable

  ROSETTA_PREFIX = "fixed.prefix"

  def name
    r(".name").t
  end
end

# Helpers
private def test_object
  TranslatableTestObject.new
end

private def test_object_with_prefix
  TranslatableTestObjectWithRosettaPrefix.new
end
