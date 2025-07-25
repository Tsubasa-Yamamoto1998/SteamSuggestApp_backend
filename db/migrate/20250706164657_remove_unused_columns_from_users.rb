class RemoveUnusedColumnsFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :name, :string
    remove_column :users, :nickname, :string
  end
end
