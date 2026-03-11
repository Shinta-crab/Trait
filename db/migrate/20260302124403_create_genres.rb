class CreateGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :genres do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :icon
      t.string :slug, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
