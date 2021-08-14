require "./spec_helper"

describe Rosetta do
  after_each do
    reset_to_default_locale
  end

  describe ".default_locale" do
    it "returns the default locale" do
      Rosetta.default_locale.should eq("en")
    end

    it "returns the available locales" do
      Rosetta.available_locales.should eq(%w[en nl])
    end
  end

  describe ".find" do
    it "fetches translations for for a given key" do
      Rosetta.find("user.first_name")
        .should eq({"en" => "First name", "nl" => "Voornaam"})
    end
  end

  describe ".t" do
    it "translates the given translations to the current locale" do
      translations_hash = Rosetta.find("user.first_name")

      Rosetta.locale.should eq("en")
      Rosetta.t(translations_hash).should eq("First name")
      Rosetta.locale = "nl"
      Rosetta.t(translations_hash).should eq("Voornaam")
    end

    it "interpolates the translation string" do
      translations_hash = Rosetta.find("interpolatable.string")

      Rosetta.t(translations_hash, {:name => "Dorothy", "day_name" => "fly day"})
        .should eq("Hi Dorothy, have a fabulous fly day!")
      Rosetta.t(translations_hash, {name: "Kenny", day_name: "kill day"})
        .should eq("Hi Kenny, have a fabulous kill day!")
      Rosetta.t(translations_hash, name: "Benny", day_name: "Hill day")
        .should eq("Hi Benny, have a fabulous Hill day!")
    end
  end
end
