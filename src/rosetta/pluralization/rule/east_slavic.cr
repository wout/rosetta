module Rosetta
  module Pluralization
    abstract struct Rule
      # Pluralization rule used for: Belarusian, Bosnian, Croatian, Russian, Serbian, Serbo-Croatian, Ukrainian.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :few, :many, :other)]
      struct EastSlavic < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          mod10 = count % 10
          mod100 = count % 100

          if mod10 == 1 && mod100 != 11
            :one
          elsif FROM_2_TO_4.includes?(mod10) && !FROM_12_TO_14.includes?(mod100)
            :few
          elsif mod10 == 0 || FROM_5_TO_9.includes?(mod10) || FROM_11_TO_14.includes?(mod100)
            :many
          else
            :other
          end
        end

        private FROM_2_TO_4   = (2..4).to_a
        private FROM_5_TO_9   = (5..9).to_a
        private FROM_11_TO_14 = (11..14).to_a
        private FROM_12_TO_14 = (12..14).to_a
      end
    end
  end
end
