class AddStatusToGenres < ActiveRecord::Migration[7.2]
  def change
    add_column :genres, :status, :integer, default: 0, null: false
  end
end
