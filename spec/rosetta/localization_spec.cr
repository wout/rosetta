require "../spec_helper"

describe Rosetta do
  after_each do
    reset_to_default_locale
  end

  describe ".localize_time" do
    it "localizes day and month names" do
      time = Time.local(1815, 12, 10, 10, 18, 15)

      Rosetta.localize_time(time, "%a %^a %A %^A")
        .should eq("Sun SUN Sunday SUNDAY")
      Rosetta.localize_time(time, "%b %^b %B %^B")
        .should eq("Dec DEC December DECEMBER")
      Rosetta.localize_time(time, "%p %P")
        .should eq("AM am")

      Rosetta.locale = "nl"
      time = Time.local(2219, 4, 10, 22, 19, 10)

      Rosetta.localize_time(time, "%a %^a %A %^A")
        .should eq("za ZA zaterdag ZATERDAG")
      Rosetta.localize_time(time, "%b %^b %B %^B")
        .should eq("apr APR april APRIL")
      Rosetta.localize_time(time, "%p %P")
        .should eq("PM pm")
    end
  end

  describe ".date" do
    it "localizes a date with a time object" do
      Rosetta.date.l(Time.local(2000, 2, 20)).should eq("2000-02-20")
    end

    it "localizes a date with a named tuple" do
      Rosetta.date.l({2000, 2, 20}).should eq("2000-02-20")
    end

    it "localizes a date according to a given predefined format" do
      Rosetta.date(:short).l({2000, 2, 20}).should eq("Feb 20")
    end

    it "localizes a date according to a given formatted string" do
      Rosetta.date("%B %Y").l(Time.local(2000, 2, 20))
        .should eq("February 2000")
    end
  end

  describe ".time" do
    it "localizes time according to a given predefined format" do
      Rosetta.time(:long).l(Time.local(1984, 6, 7, 8, 9, 10))
        .should eq("June 07, 1984 08:09")
    end

    it "localizes time according to a given predefined format" do
      Rosetta.time("%Y | %H | %m | %S").l(Time.local(1984, 6, 7, 8, 9, 10))
        .should eq("1984 | 08 | 06 | 10")
    end
  end

  describe ".number" do
    it "localizes a number " do
      Rosetta.number.l(123_456.789).should eq("123,456.79")
    end

    it "localizes a number according to a given predefined format " do
      Rosetta.number(:custom).l(123_456.789).should eq("12 34 56.789")
    end

    it "allows for individual parameters to be overridden" do
      Rosetta.number(:custom).l(123_456.789, only_significant: false)
        .should eq("12 34 56.789000")
    end
  end

  describe ".distance_of_time_in_words" do
    it "considers seconds" do
      Rosetta.distance_of_time_in_words(
        Time.utc(2019, 8, 14, 10, 0, 0),
        Time.utc(2019, 8, 14, 10, 0, 5)
      ).should eq("5 seconds")

      Rosetta.with_locale(:nl) do
        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 8, 14, 10, 0, 0),
          Time.utc(2019, 8, 14, 10, 0, 5)
        ).should eq("5 seconden")
      end
    end

    it "considers minutes" do
      Rosetta.with_locale(:nl) do
        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 8, 14, 10, 0, 0),
          Time.utc(2019, 8, 14, 10, 1, 0)
        ).should eq("een minuut")

        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 8, 14, 10, 0, 0),
          Time.utc(2019, 8, 14, 10, 12, 0)
        ).should eq("12 minuten")

        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 8, 14, 10, 0, 0),
          Time.utc(2019, 8, 14, 10, 48, 0)
        ).should eq("ongeveer een uur")
      end
    end

    it "considers hours" do
      Rosetta.with_locale(:nl) do
        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 10, 4, 10),
          Time.utc(2019, 10, 4, 11)
        ).should eq("een uur")

        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 10, 10, 1),
          Time.utc(2019, 10, 10, 13)
        ).should eq("12 uur")
      end
    end

    it "considers days" do
      Rosetta.with_locale(:nl) do
        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 10, 3),
          Time.utc(2019, 10, 4)
        ).should eq("een dag")

        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 10, 3),
          Time.utc(2019, 10, 10)
        ).should eq("7 dagen")
      end
    end

    it "considers months" do
      Rosetta.with_locale(:nl) do
        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 8, 14),
          Time.utc(2019, 10, 4)
        ).should eq("ongeveer een maand")
      end
    end

    it "considers years" do
      Rosetta.with_locale(:nl) do
        Rosetta.distance_of_time_in_words(
          Time.utc(2018, 8, 14),
          Time.utc(2019, 10, 4)
        ).should eq("ongeveer een jaar")

        Rosetta.distance_of_time_in_words(
          Time.utc(2016, 10, 4),
          Time.utc(2019, 10, 4)
        ).should eq("meer dan 3 jaar")

        Rosetta.distance_of_time_in_words(
          Time.utc(2019, 8, 14),
          Time.utc(2061, 10, 4)
        ).should eq("bijna 42 jaar")
      end
    end
  end
end
