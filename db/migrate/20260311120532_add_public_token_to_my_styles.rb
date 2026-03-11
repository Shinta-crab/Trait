class AddPublicTokenToMyStyles < ActiveRecord::Migration[7.2]
  def change
    add_column :my_styles, :public_token, :string
    add_index :my_styles, :public_token, unique: true
  end
end
