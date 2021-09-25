require "../spec_helper"

describe Rosetta do
  after_each do
    reset_to_default_locale
  end

  describe ".t" do
    it "returns a module for the given translation key" do
      translation = Rosetta.find("user.first_name")

      translation.should be_a(Rosetta::Locales::User_FirstNameTranslation)
      Rosetta.locale.should eq("en")
      translation.t.should eq("First name")

      Rosetta.locale = "nl"
      "#{translation}".should eq("Voornaam")
    end

    it "interpolates the translation string" do
      Rosetta.find("interpolatable.string")
        .t(name: "Benny", day_name: "Hill day")
        .should eq("Hi Benny, have a fabulous Hill day!")
      Rosetta.find("interpolatable.string")
        .t({name: "Kenny", day_name: "kill day"})
        .should eq("Hi Kenny, have a fabulous kill day!")
      Rosetta.find("interpolatable.string")
        .t_hash({:name => "Dorothy", "day_name" => "fly day"})
        .should eq("Hi Dorothy, have a fabulous fly day!")
    end

    it "localizes a time-formatted translation string" do
      Rosetta.find("localizable.string")
        .t({first_name: "Ada", time: Time.local(1815, 12, 10, 10, 18, 15)})
        .should eq("Ada was born on Sunday 10 December 1815 at 10:18:15.")

      Rosetta.locale = :nl

      Rosetta.find("localizable.string")
        .t(first_name: "Ada", time: Time.local(1815, 12, 10, 10, 18, 15))
        .should eq("Ada is geboren op zondag 10 december 1815 om 10:18:15.")
    end

    it "localizes time with a date formatted tuple" do
      Rosetta.find("localizable.string")
        .t({first_name: "Dada", time: {1999, 9, 19}})
        .should eq("Dada was born on Sunday 19 September 1999 at 00:00:00.")
    end

    # NOTE: uncomment this to see the compilation error
    # it "raises a compilation error when a key is missing" do
    #   Rosetta.find("i_am_definitely_not_in_one_of_the_files")
    # end

    # NOTE: uncomment this to see the compilation error
    # it "raises a comilation error when the given key is not a string literal" do
    #   description = "value"
    #
    #   Rosetta.find("i_am_a.#{description}")
    # end
  end

  describe "#translations" do
    it "returns the original translations" do
      Rosetta.find("user.first_name").translations
        .should eq({en: "First name", nl: "Voornaam"})
    end
  end

  describe "#raw" do
    it "returns an uninterpolated string for the current locale" do
      Rosetta.find("interpolatable.string").raw
        .should eq("Hi %{name}, have a fabulous %{day_name}!")
    end
  end

  describe ".with_locale" do
    it "temporarily uses a different locale" do
      Rosetta.find("user.first_name").t.should eq("First name")

      Rosetta.with_locale(:nl) do
        Rosetta.find("user.first_name").t.should eq("Voornaam")
      end

      Rosetta.find("user.first_name").t.should eq("First name")
    end
  end
end
