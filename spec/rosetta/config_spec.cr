require "../spec_helper"

describe Rosetta::Config do
  describe ".default_locale" do
    it "defines the default locale" do
      Rosetta::Config.default_locale.should eq("en")
    end
  end

  describe ".available_locales" do
    it "defines the available locales" do
      Rosetta::Config.available_locales.should eq(%w[en nl])
    end
  end
end
