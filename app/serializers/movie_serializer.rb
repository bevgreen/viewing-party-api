class MovieSerializer
    include JSONAPI::Serializer
    attributes :title, :vote_average

    def self.format_movie_list(top_movies)
        top_movies.map do |movie|
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
end