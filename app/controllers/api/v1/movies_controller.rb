class Api::V1::MoviesController < ApplicationController
    
    def index
        conn = Faraday.new(url: "https://api.themoviedb.org") do |faraday|
            faraday.headers["Authorization"] = "Bearer #{Rails.application.credentials.tmdb[:api_key]}"
            faraday.headers["Accept"] = "application/json"
        end
        
        if params[:query].present?
            response = conn.get("3/search/movie", { query: params[:query] })
        else
            response = conn.get("/3/movie/top_rated")
        end
        
        json = JSON.parse(response.body, symbolize_names: true)

        if response.success?
            top_movies = json[:results].first(20) 
            render json: MovieSerializer.format_movie_list(top_movies) #create serializer with required data
        else
            render json: { error: "Failed to fetch movies" }, status: :bad_request
        end
    end
end