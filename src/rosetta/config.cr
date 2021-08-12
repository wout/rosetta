module Rosetta
  class Config
    DEFAULT_LOCALE    = "en"
    AVAILABLE_LOCALES = %w[en]

    property locale : String?

    macro default_locale
      {% if Rosetta.has_constant?("DEFAULT_LOCALE") %}
        {{ Rosetta::DEFAULT_LOCALE }}
      {% else %}
        {{ DEFAULT_LOCALE }}
      {% end %}
    end

    macro available_locales
      {% if Rosetta.has_constant?("AVAILABLE_LOCALES") %}
        {{ Rosetta::AVAILABLE_LOCALES }}
      {% else %}
        {{ AVAILABLE_LOCALES }}
      {% end %}
    end
  end
end
