require "../spec_helper"

describe Rosetta do
  after_each do
    reset_to_default_locale
  end

  describe ".t" do
    it "returns a module for the given translation key" do
      translation = Rosetta.t("user.first_name")

      translation.should be_a(Rosetta::Locales::User::FirstName)
      Rosetta.locale.should eq("en")
      translation.to_s.should eq("First name")

      Rosetta.locale = "nl"

      "#{translation}".should eq("Voornaam")
    end

    it "interpolates the translation string" do
      Rosetta.t("interpolatable.string")
        .with(name: "Benny", day_name: "Hill day")
        .should eq("Hi Benny, have a fabulous Hill day!")
      Rosetta.t("interpolatable.string")
        .with({name: "Kenny", day_name: "kill day"})
        .should eq("Hi Kenny, have a fabulous kill day!")
      Rosetta.t("interpolatable.string")
        .with_hash({:name => "Dorothy", "day_name" => "fly day"})
        .should eq("Hi Dorothy, have a fabulous fly day!")
    end

    # NOTE: uncomment this to see the compilation error
    # it "raises a compilation error" do
    #   Rosetta.t("i_am_definitely_not_in_one_of_the_files")
    # end
  end
end
