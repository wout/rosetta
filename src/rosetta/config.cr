module Rosetta
  class Config
    getter locale : String?

    # Sets the current locale with the given value, if it's found in the
    # available locales.
    def locale=(locale : String | Symbol)
      locale = sanitized_locale(locale)
      @locale = Rosetta.available_locales.includes?(locale) ? locale : Rosetta.default_locale
    end

    # Gets the current locale or falls back to the default locale if it's not
    # defined.
    def locale : String
      @locale ||= Rosetta.default_locale
    end

    private def sanitized_locale(locale)
      return unless parts = locale.to_s.match(LOCALE_REGEX)

      [parts[1], parts[2]?].compact.join("-")
    end
  end
end
