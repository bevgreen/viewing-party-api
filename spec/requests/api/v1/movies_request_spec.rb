require "rails_helper"

RSpec.describe "Top Rated Movies Endpoint" do
    describe "happy path" do
        it "can retrieve the top 20 rated movies", :vcr do
            get "/api/v1/movies"

            expect(response).to be_successful
            json = JSON.parse(response.body, symbolize_names: true)

            
            expect(json).to be_an(Array)
            expect(json.size).to eq(20)
            first_movie = json.first

            expect(first_movie).to have_key(:id)
            expect(first_movie[:id]).to be_a(Integer)
            expect(first_movie).to have_key(:type)
            expect(first_movie[:type]).to eq("movie")
            expect(first_movie).to have_key(:attributes)
            expect(first_movie[:attributes]).to have_key(:title)
            expect(first_movie[:attributes]).to have_key(:vote_average)
        end
    end
end