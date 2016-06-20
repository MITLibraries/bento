class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :email, null: false
      t.string :uid, null: false

      t.timestamps null: false
    end

    add_index :users, :uid, unique: true
  end
end
