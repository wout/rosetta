module Rosetta
  module Pluralization
    abstract class Rule
      # Central Morocco Tamazight pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      class CentralMoroccoTamazight < Rule
        def apply(count : Float | Int) : Symbol
          if ([0, 1] + (11..99).to_a).includes?(count)
            :one
          else
            :other
          end
        end
      end
    end
  end
end
