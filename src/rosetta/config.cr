module Rosetta
  class Config
    getter locale : String?

    # Sets the current locale with the given value, if it's found in the
    # available locales.
    def locale=(locale : String | Symbol)
      locale = locale.to_s.gsub(/_/, "-")
      default = Rosetta.default_locale
      @locale = Rosetta.available_locales.includes?(locale) ? locale : default
    end

    # Gets the current locale or falls back to the default locale if it's not
    # defined.
    def locale : String
      (@locale || Rosetta.default_locale)
    end
  end
end
