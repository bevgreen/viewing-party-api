require "rails_helper"

RSpec.describe ViewingParty, type: :model do
  describe "validations" do
    it { should belong_to(:host)}
    it { should have_many(:viewing_party_users)}
    it { should have_many(:users)}
  end
end