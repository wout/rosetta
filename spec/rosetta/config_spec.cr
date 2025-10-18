require "../spec_helper"

describe Rosetta::Config do
  describe ".locale" do
    it "it returns the default locale if none is set yet" do
      config = Rosetta::Config.new

      config.locale.should eq(Rosetta.default_locale.to_s)
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

    it "accepts symbols" do
      config = Rosetta::Config.new

      config.locale.should eq("en")
      config.locale = :nl
      config.locale.should eq("nl")
      config.locale = :en_US
      config.locale.should eq("en-US")
    end

    it "handles various formats" do
      config = Rosetta::Config.new

      {
        "en"          => "en",
        "en_US"       => "en-US",
        "en-US"       => "en-US",
        "en_US.UTF-8" => "en-US",
      }.each do |given, expected|
        config.locale = given
        config.locale.should eq(expected)
      end
    end
  end
end
