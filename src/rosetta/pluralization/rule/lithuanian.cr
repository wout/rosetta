module Rosetta
  module Pluralization
    abstract struct Rule
      # Lithuanian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :few, :other)]
      struct Lithuanian < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          mod10 = count % 10
          mod100 = count % 100

          if mod10 == 1 && !FROM_11_TO_19.includes?(mod100)
            :one
          elsif FROM_2_TO_9.includes?(mod10) && !FROM_11_TO_19.includes?(mod100)
            :few
          else
            :other
          end
        end

        private FROM_2_TO_9   = (2..9).to_a
        private FROM_11_TO_19 = (11..19).to_a
      end
    end
  end
end
