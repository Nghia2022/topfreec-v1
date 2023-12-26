# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersSalesforceMatchingCInsertOrSalesforceMatchingCUpdate < ActiveRecord::Migration[6.0]
  def up
    create_trigger("salesforce_matching_c_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("salesforce.matching__c").
        after(:insert) do
      "IF NEW.recordtypeid = '01228000000gxWjAAI' THEN INSERT INTO matching_events(matching_id, old_hc_lastop, new_hc_lastop, root, old_status, new_status, created_at, updated_at) VALUES(NEW.id, NULL, NEW._hc_lastop, NEW.root__c, NULL, NEW.matching_status__c, NOW(), NOW()); END IF;"
    end

    create_trigger("salesforce_matching_c_after_update_of_matching_status_c_row_tr", :generated => true, :compatibility => 1).
        on("salesforce.matching__c").
        after(:update).
        of(:matching_status__c) do
      "IF NEW.recordtypeid = '01228000000gxWjAAI' THEN INSERT INTO matching_events(matching_id, old_hc_lastop, new_hc_lastop, root, old_status, new_status, created_at, updated_at) VALUES(NEW.id, OLD._hc_lastop, NEW._hc_lastop, NEW.root__c, OLD.matching_status__c, NEW.matching_status__c, NOW(), NOW()); END IF;"
    end
  end

  def down
    drop_trigger("salesforce_matching_c_after_insert_row_tr", "salesforce.matching__c", :generated => true)

    drop_trigger("salesforce_matching_c_after_update_of_matching_status_c_row_tr", "salesforce.matching__c", :generated => true)
  end
end
