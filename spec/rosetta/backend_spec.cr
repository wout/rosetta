require "../spec_helper"

describe Rosetta::Backend do
  describe ".find" do
    it "finds an existing key" do
      Rosetta::Backend.find("title")
        .should eq({"en" => "Title", "nl" => "Titel"})
      Rosetta::Backend.find("user.first_name")
        .should eq({"en" => "First name", "nl" => "Voornaam"})
    end

    # NOTE: uncomment these to see the compilation errors
    # it "shows a compile error for a missing locale key" do
    #   Rosetta::Backend.find("pt", "user.secret")
    #     .should eq("Ssssst")
    # end
    #
    # it "shows a compile error for a missing translation" do
    #   Rosetta::Backend.find("en", "user.secret")
    #     .should eq("Ssssst")
    # end
  end
end
