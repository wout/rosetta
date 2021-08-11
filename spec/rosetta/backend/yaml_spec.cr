require "../../spec_helper"

describe Rosetta::Backend::Yaml do
  describe ".look_up" do
    it "finds an existing key" do
      Rosetta::Backend::Yaml.look_up("en", "title").should eq("Title")
    end
  end
end
