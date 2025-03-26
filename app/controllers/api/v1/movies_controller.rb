class Api::V1::MoviesController < ApplicationController
    
    def index
        api_key = Rails.application.credentials.dig(:tmdb, :api_key) # Safely fetch key

        Rails.logger.info "Using TMDb API Key: #{api_key}"

        conn = Faraday.new(url: "https://api.themoviedb.org") do |faraday|
            faraday.headers["Authorization"] = "Bearer #{Rails.application.credentials.tmdb[:api_key]}"
            faraday.headers["Accept"] = "application/json"
        end
    
        response = conn.get("/3/movie/top_rated", { language: "en-US", page: 1 })

        Rails.logger.info "TMDb API Response Status: #{response.status}"
        Rails.logger.info "TMDb API Response Body: #{response.body}"
        json = JSON.parse(response.body, symbolize_names: true)

        if response.success?
            top_movies = json[:results].first(20) # Get only the first 20 movies
            render json: MovieSerializer.format_movie_list(top_movies) #create serializer with required data
        else
            render json: { error: "Failed to fetch movies" }, status: :bad_request
        end
    end
end