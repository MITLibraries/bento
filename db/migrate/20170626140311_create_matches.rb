class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :matches do |t|
      t.belongs_to :hint, index: true
      t.string :match

      t.timestamps
    end
  end
end
