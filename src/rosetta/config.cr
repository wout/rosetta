module Rosetta
  class Config
    getter locale : String?

    # Sets the current locale with the given value, if it's found in the
    # available locales.
    def locale=(locale : String | Symbol)
      @locale = if Rosetta.available_locales.map(&.to_s).includes?(locale.to_s)
                  locale.to_s
                else
                  # TODO: make use of a fallback here
                  Rosetta.default_locale
                end
    end

    # Gets the current locale or falls back to the default locale if it's not
    # defined.
    def locale : String
      (@locale || Rosetta.default_locale)
    end
  end
end
