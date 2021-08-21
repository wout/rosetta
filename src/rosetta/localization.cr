module Rosetta
  # Localizes date, for example:
  #
  # ```
  # Rosetta.date.with(Time.local)
  # Rosetta.date.with({2021, 8, 20})
  # Rosetta.date(:long).with(Time.local)
  # Rosetta.date("%a, %d %b %Y").with(Time.local)
  # ```
  macro date(format = :default)
    {% if format.is_a?(SymbolLiteral) %}
      LocalizedTime.new(t("rosetta.date.formats.#{format}"))
    {% else %}
      LocalizedTime.new(format)
    {% end %}
  end

  # Localizes time, for example:
  #
  # ```
  # Rosetta.time.with(Time.local)
  # Rosetta.time.with({2021, 8, 20})
  # Rosetta.time(:long).with(Time.local)
  # Rosetta.time("%a, %d %b %Y").with(Time.local)
  # ```
  macro time(format = :default)
    {% if format.is_a?(SymbolLiteral) %}
      LocalizedTime.new(t("rosetta.time.formats.#{format}"))
    {% else %}
      LocalizedTime.new(format)
    {% end %}
  end

  # TO-DO: localize numbers
  macro number(format = :default)
    t("rosetta.date.formats.#{format}")
  end

  class LocalizedTime
    getter translations

    def initialize(@translations)
    end

    def initialize(format : String)
      @translations = Rosetta.available_locales
        .each_with_object({} of String => String) do |l, t|
          t[l] = Rosetta
        end
    end

    # Localizes date and time.
    def with(
      time : Time,
      **values
    ) : String
      time.to_s(translations.with(values))
    end

    # Localizes a date as tuple.
    def with(
      date : Tuple(Int32, Int32, Int32),
      **values
    ) : String
      Time.local(*date).to_s(translations.with(values))
    end

    private def localize
    end
  end

  class LocalizedNumber
  end

  class Localization
    include Lucky::AllowedInTags

    property translations : String

    def initialize(@translations : Hash(String, String))
    end

    def raw
      translations[Rosetta.locale]
    end

    def to_s(io)
      io.puts to_s
    end
  end
end
