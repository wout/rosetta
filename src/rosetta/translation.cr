module Rosetta
  # Finds the translations for the given key as a dedicated class instance for
  # the translation, which inherits from `Rosetta::Translation`.
  #
  # If the key does not exist, a compile error will be raised.
  macro find(key)
    {% if key.is_a?(StringLiteral) %}
      {%
        class_name_from_key = key.split('.').map(&.camelcase).join('_')
        translation_class_name = "#{class_name_from_key.id}Translation".id
      %}

      {% if Rosetta::Locales.has_constant?(translation_class_name) %}
        Rosetta::Locales::{{ translation_class_name.id }}.new
      {% else %}
        {% raise "Missing translation for #{key} in all locales" %}
      {% end %}
    {% else %}
      {%
        raise <<-ERROR
        Only a StringLiteral can be used as a locale key.

          Use case to dynamically switch between locale keys. For example:

            case value
            when "one"
              Rosetta.find("key.option.one").t
            when "two"
              Rosetta.find("key.option.two").t
            else
              Rosetta.find("key.option.fallback").t
            end


        ERROR
      %}
    {% end %}
  end

  # Temporarily use a different locale.
  def self.with_locale(locale : String | Symbol)
    current_locale = Rosetta.locale
    Rosetta.locale = locale
    yield
  ensure
    Rosetta.locale = current_locale || default_locale
  end

  # Base struct for translation values.
  abstract struct Translation
    abstract def translations

    # Return the raw translation value for the current locale.
    def raw
      translations[Rosetta.locale]
    end
  end

  # Methods for translations without interpolations.
  module SimpleTranslation
    macro included
      include ::Lucky::AllowedInTags
    end

    def t
      raw
    end

    def to_s
      raw
    end

    def to_s(io)
      io.puts raw
    end
  end

  # Methods for translations with interpolations.
  module InterpolatedTranslation
    # Using a hash for interpolation is considered unsafe since the content of
    # hashes can't be checked at compile-time. Try to avoid using this method if
    # you can.
    def t_hash(values : Hash)
      Rosetta.interpolate(raw, values)
    end
  end

  # Methods for translations with pluralizable values.
  module PluralizedTranslation
    # Using a hash for interpolation is considered unsafe since the content of
    # hashes can't be checked at compile-time. Try to avoid using this method if
    # you can.
    def t_hash(values : Hash)
      unless count = values["count"]?
        message = %(Missing "count" from interpolation values)
        raise InterpolationArgumentException.new(message)
      end

      Rosetta.interpolate(Rosetta.pluralize(count.to_s.to_i, raw), values)
    end
  end
end
