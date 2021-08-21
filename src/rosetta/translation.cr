module Rosetta
  # Finds translations for the given key. The returned object is a dedicated
  # module for the translation.
  #
  # If the key does not exist, a compile error will be raised.
  macro t(key)
    {% module_name = key.split('.').map(&.camelcase).join("::") %}

    {% if Rosetta::Locales::KEYS.includes?(key) %}
      Rosetta::Locales::{{ module_name.id }}.new
    {% else %}
      {% raise "Missing translation for #{key} for all locales" %}
    {% end %}
  end

  abstract class Translation
    include Lucky::AllowedInTags

    abstract def raw : String

    # For Lucky
    def to_s(io)
      io.puts to_s
    end
  end
end
