class CreateAxes < ActiveRecord::Migration[7.2]
  def change
    create_table :axes do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :label_min, null: false
      t.string :label_max, null: false

      t.timestamps
    end
  end
end
