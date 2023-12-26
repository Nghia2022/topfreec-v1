class AddLastopToDirectionEvent < ActiveRecord::Migration[6.0]
  def change
    change_table :direction_events do |t|
      t.string :old_hc_lastop
      t.string :new_hc_lastop
    end
  end
end
