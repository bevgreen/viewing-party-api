class Api::V1::ViewingPartiesController < ApplicationController

    def create 
        viewing_party = ViewingParty.create_viewing_party(viewing_party_params)

        if viewing_party.is_a?(ErrorMessage)
            render json: { data: { message: "Viewing Party was not created", errors: [viewing_party.message] } }, status: :bad_request
        elsif viewing_party.persisted?
            render json: ViewingPartySerializer.format_party(viewing_party), status: :created
        else 
            render json: { data: { message: "Viewing Party was not created", errors: viewing_party.errors.full_messages } }, status: :unprocessable_entity
        end
    end
    
    private
    def viewing_party_params
        permitted_params = params.require(:viewing_party).permit(
            :name, 
            :start_time, 
            :end_time, 
            :movie_id, 
            :movie_title, 
            :host_id
        )
        permitted_params[:invitees] = params[:invitees] if params[:invitees].present?
        permitted_params
    end
end
