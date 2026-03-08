class CreateMyStyleSelections < ActiveRecord::Migration[7.2]
  def change
    create_table :my_style_selections do |t|
      t.references :my_style, null: false, foreign_key: true
      t.references :photo, null: false, foreign_key: true
      t.integer :pos_x, null: false # 基準軸(Simple-Detail)
      t.integer :pos_y, null: false # 基準軸(Soft-Solid)
      t.boolean :is_selected, default: false, null: false
      t.timestamps
    end
  end
end
