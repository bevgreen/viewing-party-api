class ViewingPartySerializer
  def self.format_party(viewing_party)
    {
      id: viewing_party.id,
      name: viewing_party.name,
      start_time: viewing_party.start_time,
      end_time: viewing_party.end_time,
      movie_id: viewing_party.movie_id,
      movie_title: viewing_party.movie_title,
      host_id: viewing_party.host_id,
      invitees: viewing_party.users.map do |user|
        {
          id: user.id,
          name: user.name,
          username: user.username
        }
      end
    }
  end
end