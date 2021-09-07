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
    it "builds a struct for translations without interpolations" do
      make_parser.parse!.should contain <<-MODULE
          struct TitleTranslation < Rosetta::Translation
            getter translations = {en: "Title", nl: "Titel"}
            def t
              raw
            end
          end
      MODULE
    end

    it "builds a struct for translations with interpolations" do
      make_parser.parse!.should contain <<-MODULE
          struct Interpolatable_StringTranslation < Rosetta::Translation
            getter translations = {en: "Hi %{name}, have a fabulous %{day_name}!", nl: "Hey %{name}, maak er een geweldige %{day_name} van!"}
            def t(name : String, day_name : String)
              {en: "Hi \#{name}, have a fabulous \#{day_name}!", nl: "Hey \#{name}, maak er een geweldige \#{day_name} van!"}[Rosetta.locale]
            end
            def t(values : NamedTuple(name: String, day_name: String))
              self.t(**values)
            end
          end
      MODULE
    end

    it "builds a struct for translations with localizations" do
      make_parser.parse!.should contain <<-MODULE
          struct Localizable_StringTranslation < Rosetta::Translation
            getter translations = {en: "%{first_name} was born on %A %d %B %Y at %H:%M:%S.", nl: "%{first_name} is geboren op %A %d %B %Y om %H:%M:%S."}
            def t(first_name : String, time : Time)
              Rosetta.localize_time({en: "\#{first_name} was born on %A %d %B %Y at %H:%M:%S.", nl: "\#{first_name} is geboren op %A %d %B %Y om %H:%M:%S."}[Rosetta.locale], time)
            end
            def t(values : NamedTuple(first_name: String, time: Time))
              self.t(**values)
            end
          end
      MODULE
    end

    it "returns an error when a complete locale is missing" do
      output = make_parser(available_locales: %i[en fr nl]).parse!

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
