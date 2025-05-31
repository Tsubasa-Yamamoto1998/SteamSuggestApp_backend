class AddSteamIdToUsers < ActiveRecord::Migration[8.0]
  # steamIDをusersテーブルに追加するマイグレーション、steamからのユーザー情報を保存するため
  def change
     :users, :steam_id, :string
  end
end
