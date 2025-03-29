class Api::V1::ViewingPartiesController < ApplicationController

    def create 
        viewing_party = ViewingParty.create_viewing_party(viewing_party_params)
        if viewing_party.persisted?
            render json: ViewingPartySerializer.format_party(viewing_party), status: :created
        else
            render json: { message: viewing_party.message }, status: viewing_party.status_code
        end
    end
    
    private

    def viewing_party_params
        permitted_params = params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, :host_id)

        permitted_params[:invitees] = params[:invitees] if params[:invitees].present? #refactor

        permitted_params
    end
end
