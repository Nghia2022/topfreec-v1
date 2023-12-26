# frozen_string_literal: true

# ref. https://gist.github.com/tarot/213c3d454606a68b9a36
module SchemafileNormalizer
  Table = Struct.new(:facing, :columns)

  def self.normalize!(filename)
    src = File.read(filename)
    File.write(filename, sort_column(src))
  end

  def self.sort_column(src) # rubocop:disable Metrics/AbcSize
    src.each_line.with_object([Table.new([], [])]) do |line, a|
      a << Table.new([], []) if line.match(/\Aend/)

      if line.match(/\A\s+t\./)
        a.last.columns << line
      else
        a.last.facing << line
      end
    end.map do |e| # rubocop:disable Style/MultilineBlockChain
      e.facing + e.columns.sort_by { |col| col.sub(/\A[^"]+"([^"]+)".*\Z/m, '\1') }
    end.flatten.join
  end
end

namespace :db do
  namespace :schema do
    namespace :dump do
      task salesforce: :environment do
        sh "bundle exec ridgepole --debug -c config/database.ridgepole.yml -E #{Rails.env} -o db/Schemafile.salesforce --export"
        SchemafileNormalizer.normalize!('db/Schemafile.salesforce')
      end
    end

    namespace :load do
      task salesforce: %i[check_protected_environments] do
        ApplicationRecord.connection.execute('CREATE SCHEMA IF NOT EXISTS salesforce')
        sh "bundle exec ridgepole --debug -c config/database.ridgepole.yml -E #{Rails.env} -f db/Schemafile.salesforce --apply"
      end
    end
  end
end

Rake::Task[:'db:schema:dump'].enhance(['db:schema:dump:salesforce'])
Rake::Task[:'db:schema:load'].enhance(['db:schema:load:salesforce'])
