module Rosetta
  module Pluralization
    abstract struct Rule
      # Maltese pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :few, :many, :other)]
      struct Maltese < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          mod100 = count % 100

          if count == 1
            :one
          elsif count == 0 || FROM_2_TO_10.includes?(mod100)
            :few
          elsif FROM_11_TO_19.includes?(mod100)
            :many
          else
            :other
          end
        end

        private FROM_2_TO_10  = (2..10).to_a
        private FROM_11_TO_19 = (11..19).to_a
      end
    end
  end
end
