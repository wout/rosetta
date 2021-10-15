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

  describe "#distance_of_time_in_words" do
    it "returns the distance between tow time objects in words" do
      test_object.distance_of_time_in_words(
        Time.local,
        Time.local + 21.days
      ).should eq("21 days")
    end
  end

  describe "#time_ago_in_words" do
    it "returns the time ago in words" do
      test_object.time_ago_in_words(
        Time.local(2021, 8, 30, 1, 2, 3) - 13.months
      ).should eq("about a year")
    end
  end

  describe "#time_from_now_in_words" do
    it "returns the time from now in words" do
      test_object.time_from_now_in_words(
        Time.local(2021, 8, 30, 1, 2, 3) + 37.months
      ).should eq("over 3 years")
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
