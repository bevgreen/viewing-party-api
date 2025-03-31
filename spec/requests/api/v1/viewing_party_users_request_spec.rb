require "rails_helper"

RSpec.describe "Add User to Viewing Party Endpoint", type: :request do
    describe "happy path" do
        before(:each) do
        @host = User.create!(name: "Bean", username: "bean_green_machine", password: "ilovenaps123")
        @user = User.create!(name: "Boots", username: "thesebootsweremade4walkin", password: "crazycat1997")
        @viewing_party = ViewingParty.create!(
            name: "Bean's Movie Night",
            start_time: "2025-02-01 10:00:00",
            end_time: "2025-02-01 14:30:00",
            movie_id: 278,
            movie_title: "The Shawshank Redemption",
            host_id: @host.id
        )
        end

        it "can add a valid user to an existing viewing party", :vcr do #VCR not working properly and recording cassettes, revisit and fix
        post "/api/v1/viewing_parties/#{@viewing_party.id}/invitees", params: { invitees_user_id: @user.id }

        expect(response).to be_successful
        expect(response.status).to eq(201) 

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json).to be_a(Hash)
        expect(json).to have_key(:id)
        expect(json[:name]).to eq(@viewing_party.name)
        expect(json[:movie_title]).to eq(@viewing_party.movie_title)

        invitees = json[:invitees]
        
        expect(invitees).to be_an(Array)
        expect(invitees.map { |invitee| invitee[:id] }).to include(@user.id)
        end
    end

    describe "sad paths" do
        before(:each) do
                @host = User.create!(name: "Bean", username: "bean_green_machine", password: "ilovenaps123")
                @user = User.create!(name: "Boots", username: "thesebootsweremade4walkin", password: "crazycat1997")
                @viewing_party = ViewingParty.create!(
                name: "Bev's Movie Night",
                start_time: "2025-02-01 10:00:00",
                end_time: "2025-02-01 14:30:00",
                movie_id: 278,
                movie_title: "The Shawshank Redemption",
                host_id: @host.id
                )
            end

        it "returns an error if the viewing party does not exist", :vcr  do
        post "/api/v1/viewing_parties/99999/invitees", params: { invitees_user_id: @user.id }

        expect(response.status).to eq(404)

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json).to have_key(:message)
        expect(json[:message]).to eq("Viewing Party not found")
        end

        it "returns an error if the user does not exist", :vcr  do
        post "/api/v1/viewing_parties/#{@viewing_party.id}/invitees", params: { invitees_user_id: 99999 }

        expect(response.status).to eq(404) 

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json).to have_key(:message)
        expect(json[:message]).to eq("User not found")
        end

        it "returns an error if the user is already invited", :vcr  do
        ViewingPartyUser.create!(viewing_party: @viewing_party, user: @user)

        post "/api/v1/viewing_parties/#{@viewing_party.id}/invitees", params: { invitees_user_id: @user.id }

        expect(response.status).to eq(422)

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json).to have_key(:message)
        expect(json[:message]).to eq("User is already invited")
        end
    end
end
