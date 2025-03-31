class MovieGateway
    def self.get_top_rated_movies(query = nil)
        if query.present?
            response = conn.get("3/search/movie", { query: query })
        else
            response = conn.get("/3/movie/top_rated")
        end

        json = JSON.parse(response.body, symbolize_names: true)

        json.first(20) 
    end

    def self.get_movie_runtime_by_id(movie_id)
        response = conn.get("/3/movie/#{movie_id}")

        json = JSON.parse(response.body, symbolize_names: true)
        runtime = json[:runtime]
        return runtime
    end

    private 

    def self.conn 
        Faraday.new(url: "https://api.themoviedb.org") do |faraday|
            faraday.headers["Authorization"] = "Bearer #{Rails.application.credentials.tmdb[:api_key]}"
            faraday.headers["Accept"] = "application/json"
        end
    end
end