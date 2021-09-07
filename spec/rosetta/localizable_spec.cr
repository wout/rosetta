require "../spec_helper"

describe LocalizableTestObject do
  describe "#created_on" do
    it "returns a localized date value" do
      test_object.created_on.should eq("June 07, 1984")
    end
  end

  describe "#created_at" do
    it "returns a localized time value" do
      test_object.created_at.should eq("07 Jun 08:09")
    end
  end

  describe "#seconds_since_creation" do
    it "returns a localized number value" do
      test_object.seconds_since_creation.should eq("1 174 837 850.00")
    end
  end
end

# Test objects
class LocalizableTestObject
  include Rosetta::Localizable

  def created_on
    r_date(:long).l(time_of_creation)
  end

  def created_at
    r_time(:short).l(time_of_creation)
  end

  def seconds_since_creation
    seconds = (Time.local(2021, 8, 30) - time_of_creation).to_f

    r_number(:default).l(seconds, delimiter: ' ')
  end

  private def time_of_creation
    Time.local(1984, 6, 7, 8, 9, 10)
  end
end

# Helpers
private def test_object
  LocalizableTestObject.new
end
