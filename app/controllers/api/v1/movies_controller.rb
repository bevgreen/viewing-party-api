class Api::V1::MoviesController < ApplicationController
    
    def index
        query = params[:query]
        top_movies = MovieGateway.get_top_rated_movies(query)
        render json: MovieSerializer.format_movie_list(top_movies) 
    end
end