require "rails_helper"

RSpec.describe "Viewing Parties API", type: :request do
    describe "POST /api/v1/viewing_parties" do
        before(:each) do
        @host = User.create!(name: "Bean", username: "bean_green_machine", password: "ilovenaps123")
        @user = User.create!(name: "Boots", username: "thesebootsweremade4walkin", password: "crazycat1997")
        end

        it "creates a new viewing party with valid data", :vcr do
            viewing_party_params = {
                name: "Bean's Movie Night",
                start_time: "2025-02-01 18:00:00",
                end_time: "2025-02-01 20:30:00",
                movie_id: 278,
                movie_title: "The Shawshank Redemption",
                host_id: @host.id,
                invitees: [@user.id]
            }
    
            post "/api/v1/viewing_parties", params: {viewing_party: viewing_party_params}, as: :json

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:created)
            expect(response).to have_http_status(:created)

            expect(json[:name]).to eq(viewing_party_params[:name])
            expect(Time.parse(json[:start_time])).to eq(Time.zone.parse(viewing_party_params[:start_time]))
            expect(Time.parse(json[:end_time])).to eq(Time.zone.parse(viewing_party_params[:end_time]))
            #was running into multiple failures with timing, was comparing my time zone cst to utc
            expect(json[:movie_id]).to eq(viewing_party_params[:movie_id])
            expect(json[:movie_title]).to eq(viewing_party_params[:movie_title])
            expect(json[:host_id]).to eq(viewing_party_params[:host_id])

            invitee_ids = json[:invitees].map { |invitee| invitee[:id] }
            expect(invitee_ids).to match_array(viewing_party_params[:invitees])
        end

        it "returns an error if required parameters are missing", :vcr do #skipping test currently, having difficulty with passing no params
            post "/api/v1/viewing_parties", params: {viewing_party_params: {}}, as: :json
        
            json = JSON.parse(response.body, symbolize_names: true)
            expect(json[:exception]).to eq("#<ActionController::ParameterMissing: param is missing or the value is empty: viewing_party>")
            expect(json[:error]).to eq("Bad Request")
        end

        it "returns an error if party duration is shorter than the movie runtime", :vcr do
            short_duration_party = {
                name: "Too Short Party",
                start_time: "2025-02-01 18:00:00",
                end_time: "2025-02-01 18:30:00", 
                movie_id: 278,
                movie_title: "The Shawshank Redemption",
                host_id: @host.id,
                invitees: [@user.id]
            }

            post "/api/v1/viewing_parties", params: {viewing_party: short_duration_party}, as: :json
            json = JSON.parse(response.body, symbolize_names: true)
            
            expect(response).to have_http_status(:bad_request)
            expect(json[:data][:message]).to eq("Viewing Party was not created")
            expect(json[:data][:errors]).to include("Party duration must be longer than movie runtime")
        end

        it "returns an error if invitee IDs are invalid", :vcr do
            party_with_invalid_invitees = {
                name: "Invalid Invitees Party",
                start_time: "2025-02-01 18:00:00",
                end_time: "2025-02-01 20:30:00",
                movie_id: 278,
                movie_title: "The Shawshank Redemption",
                host_id: @host.id,
                invitees: [99999] 
            }

            post "/api/v1/viewing_parties", params: {viewing_party: party_with_invalid_invitees}, as: :json

            json = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:bad_request)
            expect(json[:data][:message]).to eq("Viewing Party was not created")
            expect(json[:data][:errors]).to include("Invalid invitee IDs: 99999")
        end
    end
end
