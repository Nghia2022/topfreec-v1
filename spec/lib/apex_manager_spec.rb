# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApexManager, type: :lib do
  let(:files) { %w[FCWebToolingExample.cls FCWebToolingExampleTrigger.tgr] }
  let(:dir) { 'spec/fixtures/apex' }
  let(:apex_manager) { ApexManager.new(files, dir) }

  describe '#deploy' do
    context 'create' do
      before do
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:query).and_return([])
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:create!).and_return('id')
      end

      it do
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ApexClass', { Body: File.read(File.join(dir, files[0])) })
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ApexTrigger', { Body: File.read(File.join(dir, files[1])), TableEnumOrId: 'Account' })
        apex_manager.deploy
      end
    end

    context 'update' do
      around do |ex|
        travel_to(Time.zone.parse('2020-10-01 00:00:00')) { ex.run }
      end

      before do
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:query).and_return([instance_double('record', Id: 'id')])
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:create!).and_return('id')
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:find).and_return(instance_double('record', State: 'Completed'))
      end

      it do
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('MetadataContainer', { Name: 'FCWebContainer-20201001000000' })
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ContainerAsyncRequest', { IsCheckOnly: false, MetadataContainerId: 'id' })
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ApexClassMember', { Body: File.read(File.join(dir, files[0])), ContentEntityId: 'id', MetaDataContainerId: 'id' })
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ApexTriggerMember', { Body: File.read(File.join(dir, files[1])), ContentEntityId: 'id', MetaDataContainerId: 'id' })
        apex_manager.deploy
      end
    end
  end

  describe '#delete' do
    context 'create' do
      before do
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:query).and_return([instance_double('record', Id: 'id')])
        allow_any_instance_of(Restforce::Tooling::Client).to receive(:destroy!)
      end

      it do
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:destroy!).with('ApexClass', 'id')
        expect_any_instance_of(Restforce::Tooling::Client).to receive(:destroy!).with('ApexTrigger', 'id')
        apex_manager.delete
      end
    end
  end

  describe '#deactivate_triggers' do
    around do |ex|
      travel_to(Time.zone.parse('2020-10-01 00:00:00')) { ex.run }
    end

    before do
      allow_any_instance_of(Restforce::Tooling::Client).to receive(:query).and_return([instance_double('record', Id: 'id')])
      allow_any_instance_of(Restforce::Tooling::Client).to receive(:create!).and_return('id')
      allow_any_instance_of(Restforce::Tooling::Client).to receive(:find).and_return(instance_double('record', State: 'Completed'))
    end

    it do
      expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('MetadataContainer', { Name: 'FCWebContainer-20201001000000' })
      expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ContainerAsyncRequest', { IsCheckOnly: false, MetadataContainerId: 'id' })
      expect_any_instance_of(Restforce::Tooling::Client).to receive(:create!).with('ApexTriggerMember', { Body: File.read(File.join(dir, files[1])).gsub(/^  /, '//  '), ContentEntityId: 'id', MetaDataContainerId: 'id' })
      apex_manager.deactivate_triggers
    end
  end
end
