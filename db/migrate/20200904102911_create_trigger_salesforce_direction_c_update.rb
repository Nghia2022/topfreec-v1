# frozen_string_literal: true

# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerSalesforceDirectionCUpdate < ActiveRecord::Migration[6.0]
  def up
    create_trigger("salesforce_direction_c_after_update_of_status_c_row_tr", :generated => true, :compatibility => 1).
        on("salesforce.direction__c").
        after(:update).
        of(:status__c) do
      "INSERT INTO direction_events(direction_id, direction_sfid, old_status, new_status, created_at, updated_at) VALUES(NEW.id, NEW.sfid, OLD.status__c, NEW.status__c, NOW(), NOW());"
    end
  end

  def down
    drop_trigger('salesforce_direction_c_after_update_row_tr', 'salesforce.direction__c', generated: true)
  end
end
