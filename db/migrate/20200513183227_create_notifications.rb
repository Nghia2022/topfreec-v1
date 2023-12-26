class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :type, index: true
      t.string :subject
      t.text :body
      t.references :sender, polymorphic: true
      t.boolean :draft, default: false
      t.string :notification_code, default: nil
      t.string :link, limit: 1024
      t.references :notified_object, polymorphic: true, index: { name: :notifications_notified_object }

      t.timestamps
    end

    create_table :receipts do |t|
      t.references :receiver, polymorphic: true
      t.references :notification
      t.string :mailbox, index: true
      t.timestamp :read_at, default: nil
      t.timestamp :deleted_at, default: nil
      t.timestamps
    end
  end
end
