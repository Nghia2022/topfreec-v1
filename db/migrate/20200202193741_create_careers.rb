class CreateCareers < ActiveRecord::Migration[6.0]
  def change
    create_table :careers, id: false do |t|
      t.string :sfid, primary_key: true
      t.string :account_sfid
      t.string :company
      t.string :status
      t.string :joined
      t.text :description
      t.timestamps

      t.index :account_sfid
    end
  end
end
