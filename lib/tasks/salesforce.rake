# frozen_string_literal: true

namespace :salesforce do
  namespace :apex do
    desc 'docker compose exec -e FILES="FCWebToolingExample.cls,FCWebToolingExampleTrigger.tgr" app rails salesforce:apex:deploy'
    task deploy: %i[environment] do
      apex_manager.deploy
    end

    desc 'docker compose exec -e FILES="FCWebToolingExample.cls,FCWebToolingExampleTrigger.tgr" app rails salesforce:apex:delete'
    task delete: %i[environment] do
      apex_manager.delete
    end

    desc 'docker compose exec -e FILES="FCWebToolingExampleTrigger.tgr" app rails salesforce:apex:deactivate_triggers'
    task deactivate: %i[environment] do
      apex_manager.deactivate
    end
  end

  # ex.)
  # rails salesforce:show_field_length[Contact,Fc::EditProfile::GeneralForm]
  desc 'show length of object'
  task :show_field_length, %i[sobject_name form_name] => :environment do |_task, args|
    Salesforce::ShowFieldLengthCommand.call(args.sobject_name, args.form_name)
  end

  def apex_manager
    @apex_manager ||= ApexManager.new(ENV['FILES'].split(','))
  end
end
