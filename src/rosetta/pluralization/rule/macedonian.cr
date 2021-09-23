module Rosetta
  module Pluralization
    abstract class Rule
      # Macedonian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      class Macedonian < Rule
        def apply(count : Float | Int) : Symbol
          if count % 10 == 1 && count != 11
            :one
          else
            :other
          end
        end
      end
    end
  end
end
