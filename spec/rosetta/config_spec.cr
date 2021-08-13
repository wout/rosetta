require "../spec_helper"

describe Rosetta::Config do
  describe ".locale" do
    it "it returns the default locale if none is set yet" do
      config = Rosetta::Config.new

      config.locale.should eq(Rosetta.default_locale)
    end
  end

  describe ".locale=" do
    it "only locales registered in the available locales are accepted" do
      config = Rosetta::Config.new

      config.locale = "nl"
      config.locale.should eq("nl")
      config.locale = "pt"
      config.locale.should eq("en")
    end
  end
end
