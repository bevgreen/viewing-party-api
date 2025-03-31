class MovieDetails
   
    #MOVE TO MOVIE GATEWAY FILE 
    private 

    def self.conn 
        Faraday.new(url: "https://api.themoviedb.org") do |faraday|
            faraday.headers["Authorization"] = "Bearer #{Rails.application.credentials.tmdb[:api_key]}"
            faraday.headers["Accept"] = "application/json"
        end
    end
end
