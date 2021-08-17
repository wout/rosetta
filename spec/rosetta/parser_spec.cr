require "spec"
require "../../src/rosetta"
require "../../src/rosetta/parser"

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

      output.should contain(%("title" => {"en" => "Title", "nl" => "Titel"}))

      json = JSON.parse(output.gsub(/ => /, ':')) # a bit hackish, but does the job

      json["user.first_name"]["en"].should eq("First name")
      json["user.gender.non_binary"]["nl"].should eq("Niet-binair")
    end

    it "returns an error when a complete locale is missing" do
      output = make_parser(available_locales: %w[en fr nl]).parse!

      output.should eq <<-ERROR
      Expected to find translations for:
        ‣ en
        ‣ fr
        ‣ nl


      But missing all translations for:

        ‣ fr


      ERROR
    end

    it "returns an error when keys are missing" do
      output = make_parser(
        default_locale: "en-missing",
        available_locales: %w[en-missing nl-missing]
      ).parse!

      output.should eq <<-ERROR
      Missing keys for locale "nl-missing":
        ‣ title
        ‣ site.tagline


      ERROR
    end

    it "returns an error when there are overflowing keys" do
      output = make_parser(
        default_locale: "en-overflow",
        available_locales: %w[en-overflow nl-overflow]
      ).parse!

      output.should eq <<-ERROR
      The "nl-overflow" locale has unused keys:
        ‣ site.subtitle


      ERROR
    end

    it "returns an error when there are mismatching interpolations" do
      output = make_parser(
        default_locale: "en-interpolation",
        available_locales: %w[en-interpolation nl-interpolation]
      ).parse!

      output.should eq <<-ERROR
      Some translations have mismatching interpolation keys:
        ‣ nl-interpolation: interpolatable.missing should contain "%{pet}"
        ‣ nl-interpolation: interpolatable.one_missing should contain "%{anything}"


      ERROR
    end
  end
end

# Helpers
def make_parser(
  default_locale = "en",
  available_locales = %w[en nl]
)
  Rosetta::Parser.new(
    "spec/fixtures/rosetta",
    default_locale,
    available_locales
  )
end
