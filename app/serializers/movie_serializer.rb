class MovieSerializer
    include JSONAPI::Serializer
    attributes :title, :vote_average

    def self.format_movie_list(top_movies)
        top_movies_hash = top_movies.to_h
        movies = top_movies_hash[:results]

        movies.map do |movie|
            {
            id: movie[:id],
            type: "movie",
            attributes: {
                title: movie[:title],
                vote_average: movie[:vote_average]
            }
            }
        end
    end

    def self.format_movie_details(movie)
        {
            id: movie.id,
            type: "movie",
            attributes: {
                    title: movie.title,
                release_year: movie.release_year,
                vote_average: movie.vote_average,
                runtime: movie.runtime,
                genres: movie.genres,
                summary: movie.summary,
                cast: movie.cast,
                total_reviews: movie.total_reviews,
                reviews: movie.reviews
            }
        }
    end
end