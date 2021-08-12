require "json"
require "yaml"
require "habitat"

require "./rosetta/**"

module Rosetta
  macro find(key)
    Rosetta::Backend.look_up({{key}})
  end

  def self.t(translation : Translation) : String
    translation[locale]
  end

  def self.locale=(locale : String)
    config.locale = if settings.available_locales.includes?(locale)
                      locale
                    else
                      # TODO: make use of a fallback here
                      Config.default_locale
                    end
  end

  def self.locale : String
    config.locale || Config.default_locale
  end

  private def self.config
    Fiber.current.rosetta_config ||= Config.new
  end
end
