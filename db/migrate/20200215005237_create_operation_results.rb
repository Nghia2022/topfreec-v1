class CreateOperationResults < ActiveRecord::Migration[6.0]
  def change
    create_table :operation_results, id: false do |t|
      t.string :sfid, primary_key: true, null: true
      t.string :account_sfid
      t.string :opportunity_sfid
      t.string :name
      t.string :role
      t.text :description
      t.integer :members_num
      t.boolean :is_opened
      t.datetime :start_at
      t.datetime :end_at
      t.timestamps

      t.index :account_sfid
    end
  end
end
