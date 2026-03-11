class CreatePhotoScores < ActiveRecord::Migration[7.2]
  def change
    create_table :photo_scores do |t|
      t.references :photo, null: false, foreign_key: true
      t.references :axis, null: false, foreign_key: true
      t.integer :score, null: false

      t.timestamps

      t.index [ :photo_id, :axis_id ], unique: true
    end
  end
end
