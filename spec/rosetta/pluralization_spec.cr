require "../spec_helper"

describe Rosetta do
  describe ".pluralize" do
    it "pluralizes a given translation according to the given count" do
      translation = {
        one:   "Just the one, dear.",
        other: "There are %{count}, love.",
      }

      Rosetta.pluralize(0, translation).should eq("There are %{count}, love.")
      Rosetta.pluralize(1, translation).should eq("Just the one, dear.")
      Rosetta.pluralize(9, translation).should eq("There are %{count}, love.")
    end

    it "forces :zero if it is defined in the translations" do
      rule = Rosetta::Pluralization::Rule::OneOther.new
      translation = {
        zero:  "Nothing here, mate.",
        one:   "Just the one, dear.",
        other: "There are %{count}, love.",
      }

      Rosetta.pluralize(0, translation, rule).should eq("Nothing here, mate.")
      Rosetta.pluralize(1, translation, rule).should eq("Just the one, dear.")
      Rosetta.pluralize(9, translation, rule).should eq("There are %{count}, love.")
    end

    it "does not force :zero for rules with a relative zero" do
      rule = CustomRuleWithRelativeZero.new
      translation = {
        zero:  "Nothing here, mate.",
        few:   "Just a few, dear.",
        other: "There are %{count}, love.",
      }

      Rosetta.pluralize(0, translation, rule).should eq("Just a few, dear.")
      Rosetta.pluralize(1, translation, rule).should eq("Just a few, dear.")
      Rosetta.pluralize(3, translation, rule).should eq("Just a few, dear.")
      Rosetta.pluralize(4, translation, rule).should eq("There are %{count}, love.")
      Rosetta.pluralize(9, translation, rule).should eq("There are %{count}, love.")
    end
  end
end

# Custom pluralization rule
@[Rosetta::Pluralization::CategoryTags(:few, :other)]
struct CustomRuleWithRelativeZero < Rosetta::Pluralization::Rule
  include Rosetta::Pluralization::Rule::RelativeZero

  def apply(count : Float | Int) : Symbol
    count <= 3 ? :few : :other
  end
end
