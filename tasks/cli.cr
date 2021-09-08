require "colorize"
require "option_parser"
require "teeplate"

module Rosetta
  class Cli
    def call
      ensure_arguments
      parse_options
    rescue e : Exception
      puts e.message.colorize.red
    ensure
      exit
    end

    private def ensure_arguments
      return unless ARGV.empty?

      raise <<-ERROR
      Run "bin/rosetta --init" to generate the initial files
      ERROR
    end

    private def parse_options
      OptionParser.parse do |parser|
        parser.on("--init", "Generates the initial file structure") do
          generate_initial_setup("en", "en".split(','))
        end
      end
    end

    private def generate_initial_setup(
      default_locale : String,
      available_locales : Array(String)
    )
      template = InitTemplate.new(
        default_locale,
        available_locales,
        locales_dir
      )
      template.render ".", interactive: true, list: true, color: true
    end

    # private def generate_localization_rules
    # end

    private def config_dir
      "./config"
    end

    private def locales_dir
      "#{config_dir}/rosetta"
    end
  end

  class InitTemplate < Teeplate::FileTree
    directory "#{__DIR__}/templates/init"

    @default_locale : String
    @available_locales : Array(String)
    @locales_dir : String

    def initialize(
      @default_locale,
      @available_locales,
      @locales_dir
    )
    end
  end
end
