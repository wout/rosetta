require "../spec_helper"

describe Rosetta do
  describe ".default_locale" do
    it "returns the default locale" do
      Rosetta.default_locale.should eq(:en)
    end
  end

  describe ".available_locales" do
    it "returns the available locales" do
      Rosetta.available_locales.should eq(%i[en nl])
    end
  end
end
