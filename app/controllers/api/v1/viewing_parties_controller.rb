class Api::V1::ViewingPartiesController < ApplicationController

    def create 
        party = ViewingParty.create(viewing_party_params)
        
    end

    
    
    
    
    
    
    
    
    
    
    private

    def viewing_party_params
        params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, :host_id)
    end
    

end
