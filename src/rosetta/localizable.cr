module Rosetta
  # Include this module in any class where you need to localize many values.
  module Localizable
    delegate distance_of_time_in_words, to: Rosetta
    delegate time_ago_in_words, to: Rosetta
    delegate time_from_now_in_words, to: Rosetta

    # Finds the translations for a given format to localize a date
    macro r_date(format)
      Rosetta.date({{format}})
    end

    # Finds the translations for a given format to localize a time
    macro r_time(format)
      Rosetta.time({{format}})
    end

    # Finds the translations for a given format to localize a number
    macro r_number(format)
      Rosetta.number({{format}})
    end
  end
end
