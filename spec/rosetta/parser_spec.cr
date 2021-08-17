require "../spec_helper"
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
      json = JSON.parse(output.gsub(/ => /, ':')) # a bit hackish, but does the job

      output.should contain(%("title" => {"en" => "Title", "nl" => "Titel"}))
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
      output = make_parser(available_locales: %w[en en-missing]).parse!

      output.should eq <<-ERROR
      Missing keys for locale "en-missing":
        ‣ user.first_name
        ‣ user.last_name
        ‣ user.gender.male
        ‣ user.gender.female
        ‣ user.gender.non_binary


      ERROR
    end

    it "returns an error when there are overflowing keys" do
      output = make_parser(available_locales: %w[en en-overflow]).parse!

      output.should eq <<-ERROR
      The "en-overflow" locale has unused keys:
        ‣ i_am_overflowing
        ‣ user.email


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
