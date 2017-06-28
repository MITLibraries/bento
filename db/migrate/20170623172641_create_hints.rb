class CreateHints < ActiveRecord::Migration[5.1]
  def change
    create_table :hints do |t|
      t.string :title, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
