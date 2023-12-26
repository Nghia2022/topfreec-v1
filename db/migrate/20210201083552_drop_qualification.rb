# frozen_string_literal: true

class DropQualification < ActiveRecord::Migration[6.0]
  def up
    drop_table :qualifications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
