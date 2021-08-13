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
      translations = Rosetta.find("user.first_name")

      Rosetta.locale.should eq("en")
      Rosetta.t(translations).should eq("First name")
      Rosetta.locale = "nl"
      Rosetta.t(translations).should eq("Voornaam")
    end
  end
end
