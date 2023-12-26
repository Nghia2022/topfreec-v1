class CreateEducations < ActiveRecord::Migration[6.0]
  def change
    create_table :educations, id: false do |t|
      t.string :sfid, primary_key: true
      t.string :account_sfid
      t.string :school_name
      t.string :department
      t.string :entrance
      t.string :graduation
      t.timestamps

      t.index :account_sfid
    end
  end
end
