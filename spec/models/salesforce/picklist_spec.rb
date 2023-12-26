# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Salesforce::Picklist, type: :model do
  let(:klass) { Class.new(Salesforce::Picklist) }

  describe '.mapping' do
    describe 'where conditions' do
      subject { klass.all.where_values_hash }

      it do
        klass.mapping sobject: 'TestObject', field_name: 'TestField'

        is_expected.to eq('sobject' => 'TestObject', 'field' => 'TestField')
      end
    end
  end
end

# == Schema Information
#
# Table name: salesforce_picklist_values
#
#  id            :bigint           not null, primary key
#  active        :boolean
#  default_value :boolean
#  field         :string
#  label         :string
#  position      :integer
#  slug          :string
#  sobject       :string
#  valid_for     :string
#  value         :string
#  updated_at    :datetime
#
# Indexes
#
#  index_salesforce_picklist_values_on_position                     (position)
#  index_salesforce_picklist_values_on_sobject_and_field            (sobject,field)
#  index_salesforce_picklist_values_on_sobject_and_field_and_label  (sobject,field,label) UNIQUE
#  index_salesforce_picklist_values_on_sobject_and_field_and_slug   (sobject,field,slug) UNIQUE
#
