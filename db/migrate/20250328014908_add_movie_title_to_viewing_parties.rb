class AddMovieTitleToViewingParties < ActiveRecord::Migration[7.1]
  def change
    add_column :viewing_parties, :movie_title, :string
  end
end
