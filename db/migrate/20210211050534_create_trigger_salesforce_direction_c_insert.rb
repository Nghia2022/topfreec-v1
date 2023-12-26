# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerSalesforceDirectionCInsert < ActiveRecord::Migration[6.0]
  def up
    create_trigger("salesforce_direction_c_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("salesforce.direction__c").
        after(:insert) do
      "INSERT INTO direction_events(direction_id, direction_sfid, old_hc_lastop, new_hc_lastop, old_status, new_status, created_at, updated_at, mail_queued) VALUES(NEW.id, NEW.sfid, NULL, NEW._hc_lastop, NULL, NEW.status__c, NOW(), NOW(), NEW.ismailqueue__c);"
    end
  end

  def down
    drop_trigger("salesforce_direction_c_after_insert_row_tr", "salesforce.direction__c", :generated => true)
  end
end
