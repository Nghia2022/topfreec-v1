# frozen_string_literal: true

class AddPasswordChangedAtToFcUser < ActiveRecord::Migration[6.0]
  def change
    change_table :fc_users do |t|
      t.datetime :password_changed_at
    end
  end
end
