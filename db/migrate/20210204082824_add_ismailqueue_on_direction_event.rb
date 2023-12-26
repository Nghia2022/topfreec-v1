class AddIsmailqueueOnDirectionEvent < ActiveRecord::Migration[6.0]
  def change
    change_table :direction_events do |t|
      t.boolean :mail_queued, default: false
    end
  end
end
