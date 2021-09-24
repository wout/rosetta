module Rosetta
  module Pluralization
    abstract struct Rule
      # Pluralization rule used for: Czech, Slovak.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :few, :other)]
      struct WestSlavic < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif FROM_2_TO_4.includes?(count)
            :few
          else
            :other
          end
        end

        private FROM_2_TO_4 = (2..4).to_a
      end
    end
  end
end
