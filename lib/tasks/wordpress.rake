# frozen_string_literal: true

namespace :wordpress do
  task import_from_dev: %i[environment] do
    raise "Don't run on production!" if Rails.env.production?

    current = Rails.configuration.database_configuration['wordpress']
    dev = Rails.application.credentials.wordpress.merge(adapter: 'mysql2')

    raise "Don't run other than staging RDS!" unless current['host'].starts_with?('fcjp-wp-dev')

    dump = 'tmp/wordpress.sql'
    sh "mysqldump -u #{dev[:username]} -p#{dev[:password]} -h #{dev[:host]} #{dev[:database]} > #{dump}"
    sh "mysql -u #{current['username']} -p#{current['password']} -h #{current['host']} #{current['database']} < #{dump}"
    sh "rm #{dump}"
  end

  task credentials_args: :environment do
    db = Rails.application.credentials.wordpress

    print [
      '-h', db[:host],
      '-u', db[:username],
      "-p#{db[:password]}",
      db[:database]
    ].join(' ')
  end
end
