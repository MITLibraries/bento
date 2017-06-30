class CreateHints < ActiveRecord::Migration[5.1]
  def change
    create_table :hints do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :fingerprint, null: false
      t.timestamps
    end

    add_index :hints, :fingerprint
  end
end
