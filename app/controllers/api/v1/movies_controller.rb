class Api::V1::MoviesController < ApplicationController
    
    def index
        query = params[:query]
        top_movies = MovieGateway.get_top_rated_movies(query)
        render json: MovieSerializer.format_movie_list(top_movies) 
    end

    def show
        movie = MovieGateway.get_movie_details(params[:id])
        if movie.nil?
            render json: { error: 'Movie not found' }, status: :not_found
        else
            render json: MovieSerializer.format_movie_details(movie)
        end
    end
end