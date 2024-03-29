module Rosetta
  module Pluralization
    abstract struct Rule
      # Irish pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :two, :few, :many, :other)]
      struct Irish < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          if count == 1
            :one
          elsif count == 2
            :two
          elsif FROM_3_TO_6.includes?(count)
            :few
          elsif FROM_7_TO_10.includes?(count)
            :many
          else
            :other
          end
        end

        private FROM_3_TO_6  = (3..6).to_a
        private FROM_7_TO_10 = (7..10).to_a
      end
    end
  end
end
