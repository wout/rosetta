require "../spec_helper"

Rosetta::Lucky.integrate

describe Rosetta::AvramBackend do
  around_each do |example|
    Rosetta.with_locale(:en) { example.run }
  end

  it "provides a URL validation message with an interpolatable scheme" do
    message = Rosetta::AvramBackend.new.get(:validate_url_format)

    (message % "https").should eq("must be a valid URL beginning with https")
  end

  it "preserves fractional numeric limits" do
    backend = Rosetta::AvramBackend.new

    (backend.get(:validate_numeric_min) % 1.5).should eq("must be greater than 1.5")
    (backend.get(:validate_numeric_max) % 2.5).should eq("must be less than 2.5")
  end
end
