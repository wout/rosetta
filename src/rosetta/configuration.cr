module Rosetta
  # Tries to find the default locale configurad by the user. If it's not set,
  # the default locale defined in the config class is used.
  macro default_locale
    {% if Rosetta.has_constant?("DEFAULT_LOCALE") %}
      {{ Rosetta::DEFAULT_LOCALE }}
    {% else %}
      {{ Rosetta::Config::DEFAULT_LOCALE }}
    {% end %}
  end

  # Tries to find the available locales configurad by the user. If it's not set,
  # the available locales defined in the config class is used.
  macro available_locales
    {% if Rosetta.has_constant?("AVAILABLE_LOCALES") %}
      {{ Rosetta::AVAILABLE_LOCALES }}
    {% else %}
      {{ Rosetta::Config::AVAILABLE_LOCALES }}
    {% end %}
  end

  # Sets the current locale at runtime using the config instance stored in the
  # current fiber.
  def self.locale=(locale : String)
    config.locale = locale
  end

  # Gets the current locale at runtime using the config instance stored in the
  # current fiber.
  def self.locale : String
    config.locale
  end

  # Finds or creates a config instance in the current fiber.
  private def self.config
    Fiber.current.rosetta_config ||= Config.new
  end
end
