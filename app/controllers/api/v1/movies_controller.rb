class Api::V1::MoviesController < ApplicationController

    def index
        movies = Movie.get_top_rated_movies #create method/data logic handling in model
        render json: MovieSerializer.format_movie_list(movies) #create serializer with required data
    end
end