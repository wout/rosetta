module Rosetta
  module Pluralization
    abstract struct Rule
      # The default pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      struct OneOther < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          count == 1 ? :one : :other
        end
      end
    end
  end
end
