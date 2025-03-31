class MovieDetails
    attr_reader :id, :title, :release_year, :vote_average, :runtime, :genres, :summary, :cast, :total_reviews, :reviews
  
    def initialize(movie_data, cast_data, reviews_data)
        @id = movie_data[:id]
        @title = movie_data[:title]
        @release_year = movie_data[:release_date]&.split("-").first.to_i #splits release date into an array and grabs first thing(year), turns to int
        @vote_average = movie_data[:vote_average]
        @runtime = format_runtime(movie_data[:runtime])
        @genres = movie_data[:genres].map { |genre| genre[:name] }
        @summary = movie_data[:overview]
        @cast = cast_data.map { |member| { character: member[:character], actor: member[:name] } }
        @total_reviews = reviews_data.count
        @reviews = reviews_data.map { |review| { author: review[:author], review: review[:content] } }
    end

    private

  def format_runtime(minutes)
        hours = minutes / 60
        mins = minutes % 60
        "#{hours} hours, #{mins} minutes"
  end
end
