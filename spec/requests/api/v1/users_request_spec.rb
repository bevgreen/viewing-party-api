require "rails_helper"

RSpec.describe "Users API", type: :request do
  describe "Create User Endpoint" do
    let(:user_params) do
      {
        name: "Me",
        username: "its_me",
        password: "QWERTY123",
        password_confirmation: "QWERTY123"
      }
    end

    context "request is valid" do
      it "returns 201 Created and provides expected fields" do
        post api_v1_users_path, params: user_params, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:data][:type]).to eq("user")
        expect(json[:data][:id]).to eq(User.last.id.to_s)
        expect(json[:data][:attributes][:name]).to eq(user_params[:name])
        expect(json[:data][:attributes][:username]).to eq(user_params[:username])
        expect(json[:data][:attributes]).to have_key(:api_key)
        expect(json[:data][:attributes]).to_not have_key(:password)
        expect(json[:data][:attributes]).to_not have_key(:password_confirmation)
      end
    end

    context "request is invalid" do
      it "returns an error for non-unique username" do
        User.create!(name: "me", username: "its_me", password: "abc123")

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Username has already been taken")
        expect(json[:status]).to eq(400)
      end

      it "returns an error when password does not match password confirmation" do
        user_params = {
          name: "me",
          username: "its_me",
          password: "QWERTY123",
          password_confirmation: "QWERT123"
        }

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Password confirmation doesn't match Password")
        expect(json[:status]).to eq(400)
      end

      it "returns an error for missing field" do
        user_params[:username] = ""

        post api_v1_users_path, params: user_params, as: :json
        json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:bad_request)
        expect(json[:message]).to eq("Username can't be blank")
        expect(json[:status]).to eq(400)
      end
    end
  end

  describe "Get All Users Endpoint" do
    it "retrieves all users but does not share any sensitive data" do
      User.create!(name: "Tom", username: "myspace_creator", password: "test123")
      User.create!(name: "Oprah", username: "oprah", password: "abcqwerty")
      User.create!(name: "Beyonce", username: "sasha_fierce", password: "blueivy")

      get api_v1_users_path

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].count).to eq(3)
      expect(json[:data][0][:attributes]).to have_key(:name)
      expect(json[:data][0][:attributes]).to have_key(:username)
      expect(json[:data][0][:attributes]).to_not have_key(:password)
      expect(json[:data][0][:attributes]).to_not have_key(:password_digest)
      expect(json[:data][0][:attributes]).to_not have_key(:api_key)
    end
  end

  describe "retrieve user profile" do
    before(:each) do
      User.destroy_all
      ViewingParty.destroy_all
      ViewingPartyUser.destroy_all
    end
    it "retrieves a user's profile with hosted and invited viewing parties", :vcr do
      user = User.create!(name: "Leo DiCaprio", username: "leo_real_verified", password: "password123")

      hosted_party = ViewingParty.create!(
        name: "Titanic Watch Party",
        start_time: "2025-05-01 10:00:00",
        end_time: "2025-05-01 14:30:00",
        movie_id: 597,
        movie_title: "Titanic",
        host_id: user.id
      )

      other_user = User.create!(name: "Kate Winslet", username: "kate_w", password: "password123")

      invited_party = ViewingParty.create!(
        name: "LOTR Viewing Party",
        start_time: "2025-03-11 10:00:00",
        end_time: "2025-03-11 15:30:00",
        movie_id: 120,
        movie_title: "The Lord of the Rings: The Fellowship of the Ring",
        host_id: other_user.id
      )

      ViewingPartyUser.create!(user_id: user.id, viewing_party_id: invited_party.id)
      
      get "/api/v1/users/#{user.id}"


      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)
      expect(hosted_party.host_id).to eq(user.id)
      expect(json[:data][:id]).to eq(user.id.to_s)
      expect(json[:data][:type]).to eq("user")
      expect(json[:data][:attributes][:name]).to eq(user.name)
      expect(json[:data][:attributes][:username]).to eq(user.username)

      expect(json[:data][:attributes][:viewing_parties_hosted]).to be_an(Array)
      expect(json[:data][:attributes][:viewing_parties_hosted].size).to eq(1)
      expect(json[:data][:attributes][:viewing_parties_hosted].first[:id]).to eq(hosted_party.id)
      expect(json[:data][:attributes][:viewing_parties_hosted].first[:movie_title]).to eq("Titanic")

      expect(json[:data][:attributes][:viewing_parties_invited]).to be_an(Array)
      expect(json[:data][:attributes][:viewing_parties_invited].size).to eq(1)
      expect(json[:data][:attributes][:viewing_parties_invited].first[:movie_title]).to eq("The Lord of the Rings: The Fellowship of the Ring")
    end

    it "returns an empty array when the user has no hosted or invited parties", :vcr do
      new_user = User.create!(name: "Solo User", username: "solo_dolo", password: "password123")

      get "/api/v1/users/#{new_user.id}"


      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:attributes][:viewing_parties_hosted]).to eq([])
      expect(json[:data][:attributes][:viewing_parties_invited]).to eq([])
    end

    it "returns a 404 error when an invalid user ID is provided", :vcr do
      get "/api/v1/users/9999"


      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:message]).to eq("Invalid User ID")
      expect(json[:status]).to eq(404)
    end
  end
end