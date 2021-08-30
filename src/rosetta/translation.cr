module Rosetta
  # Finds translations for the given key. The returned object is a dedicated
  # module for the translation.
  #
  # If the key does not exist, a compile error will be raised.
  macro t(key)
    {% class_name = key.split('.').map(&.camelcase).join('_') %}

    {% if Rosetta::Locales::KEYS.includes?(key) %}
      Rosetta::Locales::{{ class_name.id }}Translation.new
    {% else %}
      {% raise "Missing translation for #{key} for all locales" %}
    {% end %}
  end

  # Base class for translation values
  abstract class Translation
    include Lucky::AllowedInTags

    abstract def translations

    def raw : String | Array(String)
      translations[Rosetta.locale]
    end

    # For values with interpolation errors, this will raise a compiler error.
    # This is intentionally to ensure no interpolation or localization values
    # are missing.
    def to_s
      self.with
    end

    # def with
    #   raw
    # end

    # For Lucky
    def to_s(io)
      io.puts to_s
    end

    # def with_hash(values : Hash(String | Symbol, String))
    #   Rosetta.interpolate(raw, values)
    # end
  end
end
