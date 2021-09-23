module Rosetta
  module Pluralization
    abstract class Rule
      # A rule that only returns the "other" pluralization category.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:other)]
      class Other < Rule
        def apply(count : Float | Int) : Symbol
          :other
        end
      end
    end
  end
end
