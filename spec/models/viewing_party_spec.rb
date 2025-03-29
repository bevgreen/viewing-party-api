require "rails_helper"

RSpec.describe ViewingParty, type: :model do
  describe "validations" do
    it { should belong_to(:host)}
    it { should have_many(:viewing_party_users)}
    it { should have_many(:users)}
  end

  describe "class methods" do
    before(:each) do
      @host = User.create!(
        name: "Beverly",
        username: "bgree143",
        password: "password123"
      )

      @party = ViewingParty.create!(
        name: "Beverly's Movie Night",
        start_time: "2025-04-01 18:00:00",
        end_time: "2025-04-01 21:00:00",
        movie_id: 278,
        movie_title: "The Shawshank Redemption",
        host_id: @host.id
      )
    end

    it "creates a viewing party with valid attributes" do
      expect(@party).to be_a(ViewingParty)
      expect(@party.name).to eq("Beverly's Movie Night")
      expect(@party.movie_title).to eq("The Shawshank Redemption")
      expect(@party.host_id).to eq(@host.id)
    end
  end
  #MORE TESTS WHEN METHODS GET REFACTORED IN VIEWING PARTY MODEL 
end