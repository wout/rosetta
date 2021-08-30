module Rosetta
  # Include this module in any class where you need to localize many values.
  module Localizable
    # Localizes a date
    macro l_date(format)
      Rosetta.date({{format}})
    end

    # Localizes time
    macro l_time(format)
      Rosetta.time({{format}})
    end

    # Localizes a number
    macro l_number(format)
      Rosetta.number({{format}})
    end
  end
end
