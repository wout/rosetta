module Rosetta
  module Pluralization
    abstract class Rule
      # Slovenian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :two, :few, :other)]
      class Slovenian < Rule
        def apply(count : Float | Int) : Symbol
          mod100 = count % 100

          if mod100 == 1
            :one
          elsif mod100 == 2
            :two
          elsif mod100 == 3 || mod100 == 4
            :few
          else
            :other
          end
        end
      end
    end
  end
end
