module Rosetta
  # Returns translations for the given key as a dedicated class instance for the
  # translation, which inherits from `Rosetta::Translation`.
  #
  # If the key does not exist, a compile error will be raised.
  macro t(key)
    {%
      class_name_from_key = key.split('.').map(&.camelcase).join('_')
      translation_class_name = "#{class_name_from_key.id}Translation".id
    %}

    {% if Rosetta::Locales.has_constant?(translation_class_name) %}
      Rosetta::Locales::{{ translation_class_name.id }}.new
    {% else %}
      {% raise "Missing translation for #{key} for all locales" %}
    {% end %}
  end

  # Base struct for translation values
  abstract struct Translation
    include Lucky::AllowedInTags

    abstract def translations
    abstract def l

    def raw : String
      translations[Rosetta.locale]
    end

    # For Lucky
    def to_s(io)
      io.puts l
    end

    def to_s
      l
    end

    # Using a hash for interpolation is considered unsafe since the content of
    # hashes can't be checked at compile-time. Try to avoid using this method if
    # you can.
    def l_hash(values : Hash(String | Symbol, String))
      Rosetta.interpolate(raw, values)
    end
  end
end
