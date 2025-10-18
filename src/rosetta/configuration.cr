@[Rosetta::DefaultLocale(:en)]
@[Rosetta::AvailableLocales(:en)]
@[Rosetta::PluralizationRules]
module Rosetta
  LOCALE_REGEX = /\A([a-z]{2,3})(?:[_-]([A-Z0-9]{2,4}))?/

  # Fetches the default locale from the corresponding annotation.
  macro default_locale
    {{@type.annotation(Rosetta::DefaultLocale).args.first.id.stringify.gsub(/_/, "-")}}
  end

  # Fetches the available locales from the corresponding annotation.
  macro available_locales
    {% locales = @type.annotation(Rosetta::AvailableLocales).args %}
    [{{locales.map(&.id.stringify.gsub(/_/, "-")).splat}}]
  end

  # Sets the current locale at runtime using the config instance stored in the
  # current fiber.
  def self.locale=(locale : String | Symbol)
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
