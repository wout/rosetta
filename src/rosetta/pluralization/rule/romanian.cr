module Rosetta
  module Pluralization
    abstract struct Rule
      # Romanian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :few, :other)]
      struct Romanian < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif count == 0 || (1..19).to_a.includes?(count % 100)
            :few
          else
            :other
          end
        end
      end
    end
  end
end
