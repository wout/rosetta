module Rosetta
  module Pluralization
    abstract class Rule
      # Scottish gaelic pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :two, :few, :other)]
      class ScottishGaelic < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1 || count == 11
            :one
          elsif count == 2 || count == 12
            :two
          elsif (FROM_3_TO_10 + FROM_13_TO_19).includes?(count)
            :few
          else
            :other
          end
        end

        private FROM_3_TO_10  = (3..10).to_a
        private FROM_13_TO_19 = (13..19).to_a
      end
    end
  end
end
