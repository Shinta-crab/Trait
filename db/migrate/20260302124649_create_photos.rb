class CreatePhotos < ActiveRecord::Migration[7.2]
  def change
    create_table :photos do |t|
      t.references :genre, null: false, foreign_key: true
      t.references :main_style, null: true, foreign_key: true
      t.string :image_path
      t.boolean :is_representative, default: false, null: false

      t.timestamps
    end
  end
end
