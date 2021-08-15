require "../spec_helper"

describe Rosetta::Parser do
  describe "#load!" do
    it "loads the locales" do
      parser = make_parser.tap(&.load!)

      parser.translations.dig("en", "user.first_name").should eq("First name")
      parser.translations.dig("nl", "user.first_name").should eq("Voornaam")
    end

    it "only loads available locales" do
      parser = make_parser(available_locales: %w[en]).tap(&.load!)

      parser.translations.dig("en", "user.first_name").should eq("First name")
      parser.translations.dig?("nl").should be_nil
    end
  end

  describe "#parse!" do
    it "flips translations and outputs the hash as a string" do
      output = make_parser.parse!
      json = JSON.parse(output.gsub(/ => /, ':')) # a bit hackish, but does the job

      output.should contain(%("title" => {"en" => "Title", "nl" => "Titel"}))
      json["user.first_name"]["en"].should eq("First name")
      json["user.gender.non_binary"]["nl"].should eq("Niet-binair")
    end
  end
end

# Helpers
def make_parser(
  default_locale = "en",
  available_locales = %w[en nl]
)
  Rosetta::Parser.new(
    "spec/fixtures/locales",
    default_locale,
    available_locales
  )
end
