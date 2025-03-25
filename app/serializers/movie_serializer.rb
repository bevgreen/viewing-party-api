class MovieSerializer
    include JSONAPI::Serializer
    attributes :title, :vote_average

    def self.format_movie_list(movies)
        { data:
            movies.map do |movie|
            {
                id: movie.id.to_s,
                type: "movie",
                attributes: {
                title: movie.title,
                vote_average: movie.vote_average #not sure yet if that is how i call those attributes of a movie
                }
            }
            end
        }
    end
end