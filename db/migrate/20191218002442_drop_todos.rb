class DropTodos < ActiveRecord::Migration[6.0]
  def up
    drop_table :todos
  end

  def down
    create_table :todos do |t|
      t.string :title, null: false
      t.timestamps
    end
  end
end
