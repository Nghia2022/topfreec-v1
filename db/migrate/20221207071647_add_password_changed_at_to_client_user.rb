# frozen_string_literal: true

class AddPasswordChangedAtToClientUser < ActiveRecord::Migration[6.0]
  def change
    change_table :client_users do |t|
      t.datetime :password_changed_at
    end
  end
end
