# frozen_string_literal: true

class CreateSalesforcePicklistValues < ActiveRecord::Migration[6.0]
  def change
    create_table :salesforce_picklist_values do |t|
      t.string :sobject
      t.string :field
      t.string :slug
      t.string :label
      t.string :value
      t.boolean :active
      t.boolean :default_value
      t.string :valid_for
      t.integer :position, index: true
      t.datetime :updated_at, default: -> { 'NOW()' }

      t.index %i[sobject field]
      t.index %i[sobject field slug], unique: true
      t.index %i[sobject field label], unique: true
    end
  end
end
