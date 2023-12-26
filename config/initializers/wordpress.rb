# frozen_string_literal: true

require 'active_record/connection_adapters/mysql2_adapter'
ActiveRecord::ConnectionAdapters::Mysql2Adapter.set_callback :checkout, :after do |connection|
  connection.execute('SET SESSION TRANSACTION READ ONLY')
end

require_relative '../../lib/strategies/phpass_strategy'
