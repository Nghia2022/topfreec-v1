class CreateEnvironments < ActiveRecord::Migration[6.0]
  def change
    create_table :environments do |t|

      t.timestamps
    end
  end
end
