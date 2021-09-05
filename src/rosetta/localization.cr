module Rosetta
  # Localizes a date, for example:
  #
  # ```
  # Rosetta.date.t(Time.local)
  # Rosetta.date.t({2021, 8, 20})
  # Rosetta.date(:long).l(Time.local)
  # Rosetta.date("%a, %d %b %Y").l(Time.local.date)
  # ```
  macro date(format = :default)
    {% if format.is_a?(SymbolLiteral) %}
      format = Rosetta.t("rosetta_localization.date.formats.{{format.id}}")
    {% else %}
      format = {{format}}
    {% end %}

    Rosetta::LocalizedTime.new(format)
  end

  # Localizes time, for example:
  #
  # ```
  # Rosetta.time.t(Time.local)
  # Rosetta.time(:short).l(Time.local)
  # Rosetta.time("%d %b %Y %H:%M:%S").l(Time.local)
  # ```
  macro time(format = :default)
    {% if format.is_a?(SymbolLiteral) %}
      format = Rosetta.t("rosetta_localization.time.formats.{{format.id}}")
    {% else %}
      format = {{format}}
    {% end %}

    Rosetta::LocalizedTime.new(format)
  end

  # Localizes a numeric value, for example:
  #
  # ```
  # Rosetta.number.t(123_456.789)
  # Rosetta.number(:custom).l(123_456.789)
  # ```
  macro number(format = :default)
    {%
      namespace = "Rosetta::Locales::RosettaLocalization_Number_Formats".id
      prefix = "#{namespace}_#{format.id.camelcase}".id
    %}

    Rosetta::LocalizedNumber.new(
      separator: {{prefix}}_SeparatorTranslation.new.to_s,
      delimiter: {{prefix}}_DelimiterTranslation.new.to_s,
      decimal_places: {{prefix}}_DecimalPlacesTranslation.new.to_s.to_i,
      group: {{prefix}}_GroupTranslation.new.to_s.to_i,
      only_significant: {{prefix}}_OnlySignificantTranslation.new.to_s == "true"
    )
  end

  # Uses a given format to localize a given Time object, for example:
  #
  # ```
  # Rosetta.localize_time("%d %b %Y %H:%M:%S", Time.local)
  # ```
  def self.localize_time(
    format : String,
    time : Time
  )
    time.to_s(localize_day_and_month_names(time, format))
  end

  {% begin %}
    {% namespace = "Rosetta::Locales::RosettaLocalization".id %}

    # Translates weekday and month names, abbreviated or full-length, uppercase
    # or in its original case.
    private def self.localize_day_and_month_names(
      time : Time,
      format : String
    ) : String
      format.gsub(/%(|\^)[aAbBpP]/) do |match|
        value = case match
                when "%a", "%^a"
                  localized_abbr_day_name(time.day_of_week.to_s).to_s
                when "%A", "%^A"
                  localized_day_name(time.day_of_week.to_s).to_s
                when "%b", "%^b"
                  localized_abbr_month_name(time.to_s("%B")).to_s
                when "%B", "%^B"
                  localized_month_name(time.to_s("%B")).to_s
                else
                  t = if time.hour < 12
                        {{namespace}}_Time_AmTranslation.new.to_s
                      else
                        {{namespace}}_Time_PmTranslation.new.to_s
                      end
                  match == "%P" ? t.downcase : t.upcase
                end

        match.index("%^") ? value.upcase : value
      end
    end

    # Returns a localizable day name
    private def self.localized_day_name(day_name : String) : String
      case day_name
      {% for name in Time::Format::DAY_NAMES %}
        when {{name}}
          {{namespace}}_Date_DayNames_{{name.id}}Translation.new.to_s
      {% end %}
      else
        raise "Unknown day name #{day_name}"
      end
    end

    # Returns a localizable, abbreviated day name
    private def self.localized_abbr_day_name(day_name : String) : String
      case day_name
      {% for name in Time::Format::DAY_NAMES %}
        when {{name}}
          {{namespace}}_Date_AbbrDayNames_{{name.id}}Translation.new.to_s
      {% end %}
      else
        raise "Unknown abbreviated day name #{day_name}"
      end
    end

    # Returns a localiable month name
    private def self.localized_month_name(month_name : String) : String
      case month_name
      {% for name in Time::Format::MONTH_NAMES %}
        when {{name}}
          {{namespace}}_Date_MonthNames_{{name.id}}Translation.new.to_s
      {% end %}
      else
        raise "Unknown month name #{month_name}"
      end
    end

    # Returns a localizable, abbreviated month name
    private def self.localized_abbr_month_name(month_name : String)
      case month_name
      {% for name in Time::Format::MONTH_NAMES %}
        when {{name}}
          {{namespace}}_Date_AbbrMonthNames_{{name.id}}Translation.new.to_s
      {% end %}
      else
        raise "Unknown abbreviated month name #{month_name}"
      end
    end
  {% end %}

  # LocalizedTime is similar to a Translation object; it implements a similar
  # interface but its sole purpose is to localize time objects.
  struct LocalizedTime
    getter format

    def initialize(translation : Translation)
      @format = translation.raw
    end

    def initialize(@format : String)
    end

    def l(time : Time)
      Rosetta.localize_time(format, time)
    end

    def l(date : Tuple(Int32, Int32, Int32))
      Rosetta.localize_time(format, Time.local(*date))
    end
  end

  # LocalizedNumber is similar to a Translation object; it implements a similar
  # interface but its sole purpose is to localize numeric objects.
  struct LocalizedNumber
    def initialize(
      @separator : String | Char,
      @delimiter : String | Char,
      @decimal_places : Int32,
      @group : Int32,
      @only_significant : Bool
    )
    end

    def l(
      number : Number,
      separator : String | Char = @separator,
      delimiter : String | Char = @delimiter,
      decimal_places : Int32 = @decimal_places,
      group : Int32 = @group,
      only_significant : Bool = @only_significant
    )
      number.format(
        separator: separator,
        delimiter: delimiter,
        decimal_places: decimal_places,
        group: group,
        only_significant: only_significant
      )
    end
  end
end
