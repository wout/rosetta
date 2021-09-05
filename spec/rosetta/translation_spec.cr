require "../spec_helper"

describe Rosetta do
  after_each do
    reset_to_default_locale
  end

  describe ".l" do
    it "returns a module for the given translation key" do
      translation = Rosetta.t("user.first_name")

      translation.should be_a(Rosetta::Locales::User_FirstNameTranslation)
      Rosetta.locale.should eq("en")
      translation.l.should eq("First name")

      Rosetta.locale = "nl"
      "#{translation}".should eq("Voornaam")
    end

    it "interpolates the translation string" do
      Rosetta.t("interpolatable.string")
        .l(name: "Benny", day_name: "Hill day")
        .should eq("Hi Benny, have a fabulous Hill day!")
      Rosetta.t("interpolatable.string")
        .l({name: "Kenny", day_name: "kill day"})
        .should eq("Hi Kenny, have a fabulous kill day!")
      Rosetta.t("interpolatable.string")
        .l_hash({:name => "Dorothy", "day_name" => "fly day"})
        .should eq("Hi Dorothy, have a fabulous fly day!")
    end

    it "localizes a time-formatted translation string" do
      Rosetta.t("localizable.string")
        .l({first_name: "Ada", time: Time.local(1815, 12, 10, 10, 18, 15)})
        .should eq("Ada was born on Sunday 10 December 1815 at 10:18:15.")

      Rosetta.locale = :nl

      Rosetta.t("localizable.string")
        .l(first_name: "Ada", time: Time.local(1815, 12, 10, 10, 18, 15))
        .should eq("Ada is geboren op zondag 10 december 1815 om 10:18:15.")
    end

    # NOTE: uncomment this to see the compilation error
    # it "raises a compilation error" do
    #   Rosetta.t("i_am_definitely_not_in_one_of_the_files")
    # end
  end

  describe "#translations" do
    it "returns the original translations" do
      Rosetta.t("user.first_name").translations
        .should eq({en: "First name", nl: "Voornaam"})
    end
  end

  describe "#raw" do
    it "returns an uninterpolated string for the current locale" do
      Rosetta.t("interpolatable.string").raw
        .should eq("Hi %{name}, have a fabulous %{day_name}!")
    end
  end
end
