require "yaml"
require "../spec_helper"

describe Rosetta::VERSION do
  describe "shard.yml" do
    it "matches the current version" do
      info = YAML.parse(File.read("./shard.yml"))

      Rosetta::VERSION.should eq(info["version"])
    end
  end
end
