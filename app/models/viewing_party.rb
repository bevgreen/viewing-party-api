class ViewingParty < ApplicationRecord
    belongs_to :host, class_name: "User", foreign_key: "host_id"

    has_many :viewing_party_users
    has_many :users, through: :viewing_party_users

    def self.create_viewing_party(viewing_party_params) 
        #refactor this huge method into smaller methods later on
        
        start_time = viewing_party_params[:start_time].to_time
        end_time = viewing_party_params[:end_time].to_time
        party_duration = (end_time - start_time) / 60
        movie_runtime = MovieGateway.get_movie_runtime_by_id(viewing_party_params[:movie_id])
        
        if end_time < start_time
            return ErrorMessage.new("End time must be after start time", 400)
        elsif party_duration < movie_runtime
            return ErrorMessage.new("Party duration must be longer than movie runtime", 400)
        end

        valid_users = []
        invalid_users = []

        viewing_party_params[:invitees].each do |user_id|
            if User.exists?(user_id)
                valid_users << user_id  
            else
                invalid_users << user_id 
            end
        end
        if invalid_users.length > 0
            error_message = "Invalid invitee IDs: #{invalid_users.join(', ')}"
            return ErrorMessage.new(error_message, 400)
        end

        party = ViewingParty.new( 
            name: viewing_party_params[:name],
            start_time: viewing_party_params[:start_time],
            end_time: viewing_party_params[:end_time],
            movie_id: viewing_party_params[:movie_id],
            movie_title: viewing_party_params[:movie_title],
            host_id: viewing_party_params[:host_id]
        )
        if party.save
            valid_users.each do |user_id|
                ViewingPartyUser.create!(viewing_party: party, user_id: user_id)
            end
        else
            return ErrorMessage.new("Failed to create Viewing Party", 422)
        end
        return party 
    end
end
