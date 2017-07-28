class AddSourceToHints < ActiveRecord::Migration[5.1]
  def change
    # we will need to delete all existing hints before this migration
    # or it will rollback. I don't want to add that step to the migration
    # as I want the person running the migration to understand the consequences
    # of deleting Hints before proceeding.
    add_column :hints, :source, :string
    change_column_null :hints, :source, false
    add_index :hints, :source
    add_index :hints, [:fingerprint, :source], unique: true
  end
end
