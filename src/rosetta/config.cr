module Rosetta
  class Config
    DEFAULT_LOCALE    = "en"
    AVAILABLE_LOCALES = %w[en]

    property locale : String?

    # Sets the current locale with the given value, if it's found in the
    # available locales.
    def locale=(locale : String)
      @locale = if Rosetta.available_locales.includes?(locale)
                  locale
                else
                  # TODO: make use of a fallback here
                  Rosetta.default_locale
                end
    end

    # Gets the current locale or falls back to the default locale if it's not
    # defined.
    def locale : String
      @locale || Rosetta.default_locale
    end
  end
end
