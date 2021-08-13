module Rosetta
  class Config
    DEFAULT_LOCALE    = "en"
    AVAILABLE_LOCALES = %w[en]

    property locale : String?

    def locale=(locale : String)
      @locale = if Rosetta.available_locales.includes?(locale)
                  locale
                else
                  # TODO: make use of a fallback here
                  Rosetta.default_locale
                end
    end

    def locale : String
      @locale || Rosetta.default_locale
    end
  end
end
