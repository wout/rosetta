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
    it "builds a module for every translation" do
      output = make_parser.parse!

      output.should contain <<-MODULE
          module Title
            extend self
            def raw
              {"en" => "Title", "nl" => "Titel"}[Rosetta.locale]
            end
            def to_s
              raw
            end
          end
      MODULE
      output.should contain <<-MODULE
          module Interpolatable::String
            extend self
            def raw
              {"en" => "Hi %{name}, have a fabulous %{day_name}!", "nl" => "Hey %{name}, maak er een geweldige %{day_name} van!"}[Rosetta.locale]
            end
            def with(name : ::String, day_name : ::String)
              self.with({name: name, day_name: day_name})
            end
            def with(values : NamedTuple(name: ::String, day_name: ::String))
              Rosetta.interpolate(raw, values)
            end
            def with_hash(values : ::Hash(::String | ::Symbol, ::String))
              Rosetta.interpolate(raw, values)
            end
            def to_s
              self.with
            end
          end
      MODULE
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

    it "returns and empty hash as string if no translations are present" do
      output = make_parser(
        default_locale: "none",
        available_locales: %w[none]
      ).parse!

      output.should eq <<-MODULE
      module Rosetta
        module Locales
          KEYS = []

        end
      end
      MODULE
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
