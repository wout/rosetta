module Rosetta
  module Pluralization
    abstract struct Rule
      # A rule that only returns the "other" pluralization category.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:other)]
      struct Other < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          :other
        end
      end
    end
  end
end
