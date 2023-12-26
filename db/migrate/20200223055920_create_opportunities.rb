class CreateOpportunities < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities, id: false do |t|
      t.string :sfid, primary_key: true, null: true
      t.string :name
      t.string :project_name
      t.text :description
      t.text :human_resources
      t.integer :compensation
      t.string :main_fc_contact_sfid
      t.string :sub_fc_contact_sfid
      t.string :account_sfid
      t.string :fc_account_sfid
      t.string :owner_sfid
      t.string :prefecture
      t.string :record_type
      t.datetime :start_at
      t.boolean :is_deleted
      t.timestamps

      t.index :account_sfid
      t.index :fc_account_sfid
    end
  end
end
