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

  describe "#localized_message_with_arguments" do
    it "accepts a time object" do
      test_object
        .localized_message_with_arguments(Time.local(1815, 12, 10, 10, 18, 15))
        .should eq("Ada was born on Sunday 10 December 1815 at 10:18:15.")
    end

    it "accepts a date-formatted tuple" do
      test_object
        .localized_message_with_arguments({1815, 12, 10})
        .should eq("Ada was born on Sunday 10 December 1815 at 00:00:00.")
    end
  end

  describe "#pluralized_message_with_arguments" do
    it "pluralizes according to the given count" do
      test_object.pluralized_message_with_arguments(1)
        .should eq("Hi Jeremy, you've got one message.")
      test_object.pluralized_message_with_arguments(23)
        .should eq("Hi Jeremy, you've got 23 messages.")
    end

    it "falls back to :other if no value is defined for :zero" do
      test_object.pluralized_message_with_arguments(0)
        .should eq("Hi Jeremy, you've got 0 messages.")
    end
  end

  describe "#pluralized_message_with_arguments_and_zero" do
    it "falls back to :other if no value is defined for :zero" do
      test_object.pluralized_message_with_arguments_and_zero(0)
        .should eq("Hi Jeremy, there are no messages.")
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

  describe "#color_variant" do
    it "returns the requested variant" do
      Rosetta.with_locale(:nl) do
        test_object.color_variant("teal").should eq("appelblauwzeegroen")
        test_object.color_variant("yellow").should eq("geel")
      end
    end
  end

  describe "#default_value" do
    it "uses the default value provided at lookup" do
      test_object.default_value.should eq("default value")
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

describe RosettaTranslatableTestObjectWithTypeVariable(SomeTestObject) do
  describe "#name" do
    it "uses the defined prefix" do
      test_object_with_type_var.name
        .should eq("With type var called SomeTestObject")
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

  def localized_message_with_arguments(time)
    r("localizable.string").t(first_name: "Ada", time: time)
  end

  def pluralized_message_with_arguments(count)
    r("pluralizable.string").t(name: "Jeremy", count: count)
  end

  def pluralized_message_with_arguments_and_zero(count)
    r("pluralizable.string_with_zero").t(name: "Jeremy", count: count)
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

  def color_variant(variant)
    r("color_variants").t(variant: variant)
  end

  def default_value
    r("i_am_definitely_not_in_one_of_the_files", "default value").t
  end
end

@[Rosetta::Translatable::Config(prefix: "fixed.prefix")]
class TranslatableTestObjectWithRosettaPrefix
  include Rosetta::Translatable

  def name
    r(".name").t
  end
end

class RosettaTranslatableTestObjectWithTypeVariable(T)
  include Rosetta::Translatable

  def name
    r(".name").t(type_var_name: T.to_s)
  end
end

class SomeTestObject
end

# Helpers
private def test_object
  TranslatableTestObject.new
end

private def test_object_with_prefix
  TranslatableTestObjectWithRosettaPrefix.new
end

private def test_object_with_type_var
  RosettaTranslatableTestObjectWithTypeVariable(SomeTestObject).new
end
