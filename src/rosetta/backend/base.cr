module Rosetta
  module Backend
    abstract class Base
      macro load(path)
        {% parser_name = @type.name.split("::").last.underscore %}

        TRANSLATIONS = {{ run("./parser/yaml", path) }}
      end

      macro look_up(locale, key)
        {% translations = TRANSLATIONS[locale] %}
        {% raise "Missing locale #{locale}" if translations.is_a?(NilLiteral) %}
        {% translation = translations[key] %}
        {% raise "Missing key #{key}" if translation.is_a?(NilLiteral) %}
        {{translation}}
      end
    end
  end
end
