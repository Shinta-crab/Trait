class AddAccountNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :account_name, :string, null: false
    # アカウント名の重複を防ぎ、検索を速くする
    add_index :users, :account_name, unique: true
  end
end
