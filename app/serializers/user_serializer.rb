class UserSerializer
  include JSONAPI::Serializer
  attributes :name, :username, :api_key

  def self.format_user_list(users)
    { data:
        users.map do |user|
          {
            id: user.id.to_s,
            type: "user",
            attributes: {
              name: user.name,
              username: user.username
            }
          }
        end
    }
  end

  def self.format_user_profile(user)
    {
      data: {
        id: user.id.to_s,
        type: "user",
        attributes: {
          name: user.name,
          username: user.username,
          viewing_parties_hosted: user.hosted_parties.map do |party|
            {
              id: party.id,
              name: party.name,
              start_time: party.start_time,
              end_time: party.end_time,
              movie_id: party.movie_id,
              movie_title: party.movie_title,
              host_id: party.host_id
            }
          end,
  
          viewing_parties_invited: user.viewing_parties
                                        .joins(:viewing_party_users)
                                        .where(viewing_party_users: { user_id: user.id })
                                        .where.not(host_id: user.id)
                                        .distinct
                                        .map do |party|
            {
              id: party.id,
              name: party.name,
              start_time: party.start_time,
              end_time: party.end_time,
              movie_id: party.movie_id,
              movie_title: party.movie_title,
              host_id: party.host_id
            }
          end
        }
      }
    }
  end  
end