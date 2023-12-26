class CreateDirectionEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :direction_events do |t|
      t.integer :direction_id, index: true
      t.string :direction_sfid, index: true
      t.string :old_status
      t.string :new_status
      t.timestamps
    end
  end
end
