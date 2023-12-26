class AddIndexToImpressions < ActiveRecord::Migration[6.0]
  def change
    add_index :impressions, %i[impressionable_type user_id message], name: 'impressionable_type_user_id_message_index', unique: false, length: { message: 255 }
  end
end
