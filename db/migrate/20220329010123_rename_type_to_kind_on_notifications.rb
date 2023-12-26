class RenameTypeToKindOnNotifications < ActiveRecord::Migration[6.0]
  def change
    rename_column :notifications, :type, :kind

    reversible do |dir|
      dir.up do
        Notification.reset_column_information
        
        matching_subjects = (0...Settings.entry_limit).map { |remaining| Projects::Entry::Matching.new.send(:notification_subject, remaining) }
        Notification.where(subject: matching_subjects).update_all(kind: :matching_remaining)
        Notification.where(kind: nil).update_all(kind: :direction_workflow) 
      end
    end
  end
end
