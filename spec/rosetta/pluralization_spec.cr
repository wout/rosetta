require "../spec_helper"

describe Rosetta do
  describe ".pluralize" do
    it "pluralizes a given translation according to the given count" do
      translation = {one: "Just the one, dear.", other: "There are many, love."}

      Rosetta.pluralize(1, translation).should eq("Just the one, dear.")
      Rosetta.pluralize(9, translation).should eq("There are many, love.")
    end
  end
end
