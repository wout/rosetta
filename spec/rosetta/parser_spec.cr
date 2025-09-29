require "spec"
require "../../src/rosetta"
require "../../src/rosetta/parser"
require "../../src/rosetta/parser/config"

describe Rosetta::Parser do
  describe "#initializer" do
    it "loads the locales" do
      parser = make_parser

      parser.translations.dig("en", "user.first_name").should eq("First name")
      parser.translations.dig("nl", "user.first_name").should eq("Voornaam")
    end

    it "only loads available locales" do
      parser = make_parser(available_locales: %w[en])

      parser.translations.dig("en", "user.first_name").should eq("First name")
      parser.translations.dig?("nl").should be_nil
    end
  end

  describe "#parse!" do
    it "builds a struct for translations without interpolations" do
      make_parser.parse!.should contain <<-MODULE
          struct TitleTranslation < Rosetta::Translation
            getter translations = {en: %(Title), "en-US": %(Title), nl: %(Titel)}
            include Rosetta::SimpleTranslation
          end
      MODULE
    end

    it "builds a struct for translations with interpolations" do
      make_parser.parse!.should contain <<-MODULE
          struct Interpolatable_StringTranslation < Rosetta::Translation
            getter translations = {en: %(Hi %{name}, have a fabulous %{day_name}!), "en-US": %(Hi %{name}, have a fabulous %{day_name}!), nl: %(Hey %{name}, maak er een geweldige %{day_name} van!)}
            include Rosetta::InterpolatedTranslation
            def t(day_name : String, name : String)
              {en: %(Hi \#{name}, have a fabulous \#{day_name}!), "en-US": %(Hi \#{name}, have a fabulous \#{day_name}!), nl: %(Hey \#{name}, maak er een geweldige \#{day_name} van!)}[Rosetta.locale]
            end
            def t(values : NamedTuple(day_name: String, name: String))
              self.t(**values)
            end
            def to_s(io)
              {%
                raise <<-ERROR

                  Rosetta.find("interpolatable.string") expected to receive
                  t(day_name : String, name : String) but to_s was called instead.

                  This error may be caused by implicitly or explicitly calling
                  .to_s on a Rosetta::Translation with interpolations.

                  Make sure you're not using Rosetta::Translation in a string
                  interpolation or in a type union with String.

                ERROR
              %}
            end
          end
      MODULE
    end

    it "builds a struct for translations with localizations" do
      make_parser.parse!.should contain <<-MODULE
          struct Localizable_StringTranslation < Rosetta::Translation
            getter translations = {en: %(%{first_name} was born on %A %d %B %Y at %H:%M:%S.), "en-US": %(%{first_name} was born on %A %d %B %Y at %H:%M:%S.), nl: %(%{first_name} is geboren op %A %d %B %Y om %H:%M:%S.)}
            include Rosetta::InterpolatedTranslation
            def t(first_name : String, time : Time | Tuple(Int32, Int32, Int32))
              Rosetta.localize_time(time, {en: %(\#{first_name} was born on %A %d %B %Y at %H:%M:%S.), "en-US": %(\#{first_name} was born on %A %d %B %Y at %H:%M:%S.), nl: %(\#{first_name} is geboren op %A %d %B %Y om %H:%M:%S.)}[Rosetta.locale])
            end
            def t(values : NamedTuple(first_name: String, time: Time | Tuple(Int32, Int32, Int32)))
              self.t(**values)
            end
            def to_s(io)
              {%
                raise <<-ERROR

                  Rosetta.find("localizable.string") expected to receive
                  t(first_name : String, time : Time | Tuple(Int32, Int32, Int32)) but to_s was called instead.

                  This error may be caused by implicitly or explicitly calling
                  .to_s on a Rosetta::Translation with interpolations.

                  Make sure you're not using Rosetta::Translation in a string
                  interpolation or in a type union with String.

                ERROR
              %}
            end
          end
      MODULE
    end

    it "builds a struct for pluralizable translations" do
      make_parser.parse!.should contain <<-MODULE
          struct Pluralizable_StringTranslation < Rosetta::Translation
            getter translations = {en: {one: %(Hi %{name}, you've got one message.), other: %(Hi %{name}, you've got %{count} messages.)}, "en-US": {one: %(Hi %{name}, you've got one message.), other: %(Hi %{name}, you've got %{count} messages.)}, nl: {one: %(Hey %{name}, je hebt een bericht.), other: %(Hey %{name}, je hebt %{count} berichten.)}}
            include Rosetta::PluralizedTranslation
            def t(count : Rosetta::CountArg, name : String)
              Rosetta.pluralize(count, {en: {one: %(Hi \#{name}, you've got one message.), other: %(Hi \#{name}, you've got \#{count} messages.)}, "en-US": {one: %(Hi \#{name}, you've got one message.), other: %(Hi \#{name}, you've got \#{count} messages.)}, nl: {one: %(Hey \#{name}, je hebt een bericht.), other: %(Hey \#{name}, je hebt \#{count} berichten.)}}[Rosetta.locale])
            end
            def t(values : NamedTuple(count: Rosetta::CountArg, name: String))
              self.t(**values)
            end
            def to_s(io)
              {%
                raise <<-ERROR

                  Rosetta.find("pluralizable.string") expected to receive
                  t(count : Rosetta::CountArg, name : String) but to_s was called instead.

                  This error may be caused by implicitly or explicitly calling
                  .to_s on a Rosetta::Translation with interpolations.

                  Make sure you're not using Rosetta::Translation in a string
                  interpolation or in a type union with String.

                ERROR
              %}
            end
          end
      MODULE
    end

    it "builds a struct for pluralizable, localizable translations" do
      make_parser.parse!.should contain <<-MODULE
          struct Pluralizable_Localizable_StringTranslation < Rosetta::Translation
            getter translations = {en: {one: %(You have an appointment on %A at %H:%M.), other: %(You have %{count} appointments on %A at %H:%M.)}, "en-US": {one: %(You have an appointment on %A at %H:%M.), other: %(You have %{count} appointments on %A at %H:%M.)}, nl: {one: %(Je hebt een afspraak op %A om %H:%M.), other: %(Je hebt %{count} afspraken op %A om %H:%M.)}}
            include Rosetta::PluralizedTranslation
            def t(count : Rosetta::CountArg, time : Time | Tuple(Int32, Int32, Int32))
              Rosetta.localize_time(time, Rosetta.pluralize(count, {en: {one: %(You have an appointment on %A at %H:%M.), other: %(You have \#{count} appointments on %A at %H:%M.)}, "en-US": {one: %(You have an appointment on %A at %H:%M.), other: %(You have \#{count} appointments on %A at %H:%M.)}, nl: {one: %(Je hebt een afspraak op %A om %H:%M.), other: %(Je hebt \#{count} afspraken op %A om %H:%M.)}}[Rosetta.locale]))
            end
            def t(values : NamedTuple(count: Rosetta::CountArg, time: Time | Tuple(Int32, Int32, Int32)))
              self.t(**values)
            end
            def to_s(io)
              {%
                raise <<-ERROR

                  Rosetta.find("pluralizable.localizable.string") expected to receive
                  t(count : Rosetta::CountArg, time : Time | Tuple(Int32, Int32, Int32)) but to_s was called instead.

                  This error may be caused by implicitly or explicitly calling
                  .to_s on a Rosetta::Translation with interpolations.

                  Make sure you're not using Rosetta::Translation in a string
                  interpolation or in a type union with String.

                ERROR
              %}
            end
          end
      MODULE
    end

    it "builds a struct for variant translations" do
      make_parser.parse!.should contain <<-MODULE
          struct ColorVariantsTranslation < Rosetta::Translation
            getter translations = {en: {pink: %(pink), teal: %(teal), yellow: %(yellow)}, "en-US": {pink: %(pink), teal: %(teal), yellow: %(yellow)}, nl: {pink: %(roze), teal: %(appelblauwzeegroen), yellow: %(geel)}}
            include Rosetta::VariantsTranslation
            def t(variant : String)
              translations[Rosetta.locale][variant]
            end
            def t(values : NamedTuple(variant: String))
              self.t(**values)
            end
            def to_s(io)
              {%
                raise <<-ERROR

                  Rosetta.find("color_variants") expected to receive
                  t(variant : String) but to_s was called instead.

                  This error may be caused by implicitly or explicitly calling
                  .to_s on a Rosetta::Translation with interpolations.

                  Make sure you're not using Rosetta::Translation in a string
                  interpolation or in a type union with String.

                ERROR
              %}
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
        ‣ nl-interpolation: "interpolatable.missing" should contain "%{pet}"
        ‣ nl-interpolation: "interpolatable.one_missing" should contain "%{anything}"


      ERROR
    end

    it "returns an error when there are missing category tags for pluralizations" do
      output = make_parser(
        default_locale: "en-pluralization",
        available_locales: %w[en-pluralization nl-pluralization],
        pluralization_rules: {
          "en-pluralization": "Rosetta::Pluralization::Rule::OneOther",
          "nl-pluralization": "Rosetta::Pluralization::Rule::OneFewOther",
        },
        pluralization_tags: {
          "Rosetta::Pluralization::Rule::OneFewOther": %w[one few other],
          "Rosetta::Pluralization::Rule::OneOther":    %w[one other],
        }
      ).parse!

      output.should eq <<-ERROR
      Some pluralizable translations are missing category tags:
        ‣ en-pluralization: "there" is missing "one"
        ‣ nl-pluralization: "inbox.messages" is missing "few"


      ERROR
    end

    it "returns an error when there are missing variant keys" do
      output = make_parser(
        default_locale: "en-variants",
        available_locales: %w[en-variants nl-variants]
      ).parse!

      output.should eq <<-ERROR
      Some translations with variants have mismatching keys:
        ‣ nl-variants: "color_variants" is missing "yellow"


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
  available_locales = %w[en en-US nl],
  fallback_rules = {
    "en-US": :en,
  },
  pluralization_rules = {
    en: "Rosetta::Pluralization::Rule::OneOther",
    nl: "Rosetta::Pluralization::Rule::OneOther",
  },
  pluralization_tags = {
    "Rosetta::Pluralization::Rule::OneOther": %w[one other],
  },
)
  parser_config = Rosetta::Parser::Config.from_yaml({
    path:                "spec/fixtures/rosetta",
    default_locale:      default_locale,
    available_locales:   available_locales,
    fallback_rules:      fallback_rules,
    pluralization_rules: pluralization_rules,
    pluralization_tags:  pluralization_tags,
  }.to_yaml)

  Rosetta::Parser.new(parser_config)
end
