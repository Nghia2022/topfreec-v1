class CreateMatchingEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :matching_events do |t|
      t.integer :matching_id, index: true
      t.string :root
      t.string :new_status
      t.string :old_status
      t.string :old_hc_lastop
      t.string :new_hc_lastop

      t.timestamps
    end
  end
end
