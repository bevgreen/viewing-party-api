require "rails_helper"

RSpec.describe "Movie Controller Tests" do
    describe "Index Method" do
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

        it "can retrive movies based on search query ", :vcr do
            get "/api/v1/movies", params: { query: "Shawshank" }

            expect(response).to be_successful
            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to be_an(Array)
            first_movie = json.first
            expect(first_movie[:attributes][:title]).to include("Shawshank")

        end
    end

    describe "Show Movie Details Method" do
        it "returns details for a specific movie", :vcr do
            movie_id = 155
        
            get "/api/v1/movies/#{movie_id}"
        
            expect(response).to have_http_status(:success)
            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to be_a(Hash)
            expect(json).to have_key(:id)
            expect(json).to have_key(:type)
            expect(json[:attributes]).to have_key(:title)
            expect(json[:attributes]).to have_key(:release_year)
            expect(json[:attributes]).to have_key(:vote_average)
            expect(json[:attributes]).to have_key(:runtime)
            expect(json[:attributes]).to have_key(:genres)
            expect(json[:attributes]).to have_key(:summary)
            expect(json[:attributes]).to have_key(:cast)
            expect(json[:attributes]).to have_key(:total_reviews)
            expect(json[:attributes]).to have_key(:reviews)
        end

        it "returns a 404 error when the movie is not found", :vcr do
            get "/api/v1/movies/9999999048390485"

            expect(response).to have_http_status(:not_found)
            json = JSON.parse(response.body, symbolize_names: true)

            expect(json).to have_key(:error)
            expect(json[:error]).to eq("Movie not found")
        end
    end
end