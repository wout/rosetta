module Rosetta
  # Include this module in any class where you need to localize many values.
  module Localizable
    # Retrieves a date localizer
    macro r_date(format)
      Rosetta.date({{format}})
    end

    # Retrieves a time localizer
    macro r_time(format)
      Rosetta.time({{format}})
    end

    # Retrieves a number localizer
    macro r_number(format)
      Rosetta.number({{format}})
    end
  end
end
