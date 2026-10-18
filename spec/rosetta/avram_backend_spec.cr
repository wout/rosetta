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
end
