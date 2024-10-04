class DropHints < ActiveRecord::Migration[7.0]
  def change
    return unless table_exists?(:hints)

    drop_table :hints
  end
end
