class AddDetailColumnsToProjects < ActiveRecord::Migration[6.0]
  def change
    remove_column :projects, :start_at, :datetime
    add_column :projects, :intern, :boolean, null: false, default: false
    add_column :projects, :period, :string
    add_column :projects, :published_at, :string
    add_column :projects, :unpublished_at, :string
    add_column :projects, :operating_rate, :integer
    add_column :projects, :contract_type, :string
    add_column :projects, :operator_name, :string
    add_column :projects, :operator_comment, :text
    add_column :projects, :recruiting, :string
  end
end
