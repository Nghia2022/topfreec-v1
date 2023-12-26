# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerSalesforceContactUpdate < ActiveRecord::Migration[6.0]
  def up
    create_trigger("salesforce_contact_after_update_of_email_row_tr", :generated => true, :compatibility => 1).
        on("salesforce.contact").
        after(:update).
        of(:email) do
      "IF NEW.recordtypename__c = 'FC' THEN UPDATE fc_users SET email = NEW.email WHERE fc_users.contact_sfid = NEW.sfid; ELSIF NEW.recordtypename__c = 'クライアント' THEN UPDATE client_users SET email = NEW.email WHERE client_users.contact_sfid = NEW.sfid; END IF;"
    end
  end

  def down
    drop_trigger("salesforce_contact_after_update_of_email_row_tr", "salesforce.contact", :generated => true)
  end
end
