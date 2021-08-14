module Rosetta
  macro default_locale
    {% if Rosetta.has_constant?("DEFAULT_LOCALE") %}
      {{ Rosetta::DEFAULT_LOCALE }}
    {% else %}
      {{ Rosetta::Config::DEFAULT_LOCALE }}
    {% end %}
  end

  macro available_locales
    {% if Rosetta.has_constant?("AVAILABLE_LOCALES") %}
      {{ Rosetta::AVAILABLE_LOCALES }}
    {% else %}
      {{ Rosetta::Config::AVAILABLE_LOCALES }}
    {% end %}
  end

  def self.locale=(locale : String)
    config.locale = locale
  end

  def self.locale : String
    config.locale
  end

  private def self.config
    Fiber.current.rosetta_config ||= Config.new
  end
end
