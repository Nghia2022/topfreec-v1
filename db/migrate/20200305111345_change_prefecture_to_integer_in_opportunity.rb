class ChangePrefectureToIntegerInOpportunity < ActiveRecord::Migration[6.0]
  def change
    change_column :opportunities, :prefecture, 'integer USING CAST(prefecture AS integer)'
  end
end
