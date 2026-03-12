class CreateMyStyles < ActiveRecord::Migration[7.2]
  def change
    create_table :my_styles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true
      t.references :analysis_result, null: false, foreign_key: true
      t.string :custom_name, default: "My Style"
      t.integer :style_type, default: 0 # 0:Solo, 1:Duo, 2:Trio
      t.timestamps
    end
  end
end
