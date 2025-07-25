class AddTrackableToUsers < ActiveRecord::Migration[8.0]
  # trackableモジュールに対するマイグレーション、不要そうだったらモジュールごと削除しても良い
  # 2023年10月時点では、trackableモジュールはデフォルトで有効になっているので、
  # マイグレーションファイルを作成してtrackableのカラムを追加する必要がある
  def change
    change_table :users, bulk: true do |t|
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  end
end
