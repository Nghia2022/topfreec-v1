class CreateSalesforceApiLimitStats < ActiveRecord::Migration[6.0]
  def change
    create_table :salesforce_api_limit_stats do |t|
      t.integer :daily_api_requests_max
      t.integer :daily_api_requests_remaining
      t.integer :daily_api_requests_calls
      t.timestamps
    end
  end
end
