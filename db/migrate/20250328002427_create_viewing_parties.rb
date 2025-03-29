class CreateViewingParties < ActiveRecord::Migration[7.1]
  def change
    create_table :viewing_parties do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.integer :movie_id
      t.integer :host_id

      t.timestamps
    end
    add_foreign_key :viewing_parties, :users, column: :host_id
  end
end
