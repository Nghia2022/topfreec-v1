class RenameEntranceOnEducations < ActiveRecord::Migration[6.0]
  def change
    rename_column :educations, :entrance, :joined
    rename_column :educations, :graduation, :left
  end
end
