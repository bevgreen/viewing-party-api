class Api::V1::ViewingPartyUsersController < ApplicationController

    def create
        party = ViewingParty.find_by(id: params[:id])
        if party.nil?
            return render json: ErrorSerializer.format_error(ErrorMessage.new("Viewing Party not found", 404)), status: :not_found
        end
        user = User.find_by(id: params[:invitees_user_id])
        if user.nil?
            return render json: ErrorSerializer.format_error(ErrorMessage.new("User not found", 404)), status: :not_found
        end

        if party.users.include?(user)
            return render json: ErrorSerializer.format_error(ErrorMessage.new("User is already invited", 422)), status: :unprocessable_entity
        end

        ViewingPartyUser.create!(viewing_party: party, user: user)

        render json: ViewingPartySerializer.format_party(party), status: :created
    end
end

