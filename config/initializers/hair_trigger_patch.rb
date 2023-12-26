# frozen_string_literal: true

# hairtriggerをsalesforceスキーマに対応させるためのパッチ
module HairTrigger
  module AdapterExtension
    # :reek:DuplicateMethodCall, :reek:TooManyStatements
    def triggers(options = {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      triggers = {}
      name_clause = options[:only] ? "IN ('#{options[:only].join("', '")}')" : nil
      adapter_name = HairTrigger.adapter_name_for(self)
      case adapter_name
      when :sqlite
        select_rows("SELECT name, sql FROM sqlite_master WHERE type = 'trigger' #{name_clause ? " AND name #{name_clause}" : ''}").each do |(name, definition)|
          triggers[name] = "#{quote_table_name_in_trigger(definition)};\n"
        end
      when :mysql
        select_rows('SHOW TRIGGERS').each do |(name, event, table, actions, timing, _created, _sql_mode, definer)|
          definer = normalize_mysql_definer(definer)
          next if options[:only]&.exclude?(name)

          triggers[name.strip] = <<~SQL.squish
            CREATE #{definer == implicit_mysql_definer ? '' : "DEFINER = #{definer} "}TRIGGER #{name} #{timing} #{event} ON `#{table}`
            FOR EACH ROW
            #{actions}
          SQL
        end
      when :postgresql, :postgis
        function_conditions = +"(SELECT typname FROM pg_type WHERE oid = prorettype) = 'trigger'"
        function_conditions << <<-SQL.squish unless options[:simple_check]
            AND oid IN (
              SELECT tgfoid
              FROM pg_trigger
              WHERE NOT tgisinternal AND tgconstrrelid = 0 AND tgrelid IN (
                SELECT oid FROM pg_class WHERE relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname IN ('public', 'salesforce'))
              )
            )
        SQL

        sql = <<-SQL.squish
            SELECT tgname::varchar, pg_get_triggerdef(oid, true)
            FROM pg_trigger
            WHERE NOT tgisinternal AND tgconstrrelid = 0 AND tgrelid IN (
              SELECT oid FROM pg_class WHERE relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname IN ('public', 'salesforce'))
            )

            #{name_clause ? " AND tgname::varchar #{name_clause}" : ''}
            UNION
            SELECT proname || '()', pg_get_functiondef(oid)
            FROM pg_proc
            WHERE #{function_conditions}
              #{name_clause ? " AND (proname || '()')::varchar #{name_clause}" : ''}
        SQL
        select_rows(sql).each do |(name, definition)|
          triggers[name] = quote_table_name_in_trigger(definition)
        end
      else
        raise "don't know how to retrieve #{adapter_name} triggers yet"
      end
      triggers
    end
  end
end

module HairTrigger
  module SchemaDumper
    module TrailerWithTriggersSupportExtension
      # :reek:DuplicateMethodCall :reek:NestedIterators, :reek:TooManyStatements
      def triggers(stream) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        @adapter_name = @connection.adapter_name.downcase.to_sym

        all_triggers = @connection.triggers
        db_trigger_warnings = {}
        migration_trigger_builders = []

        db_triggers = whitelist_triggers(all_triggers)

        migration_triggers = HairTrigger.current_migrations(in_rake_task: true, previous_schema: self.class.previous_schema).map do |(_, builder)|
          definitions = []
          builder.generate.each do |statement|
            next unless statement =~ /\ACREATE(.*TRIGGER| FUNCTION) ([^ \n]+)/

            # poor man's unquote
            type = (Regexp.last_match(1) == ' FUNCTION' ? :function : :trigger)
            name = Regexp.last_match(2).gsub('"', '')

            definitions << [name, statement, type]
          end
          { builder:, definitions: }
        end

        migration_triggers.each do |migration|
          next unless migration[:definitions].all? do |(name, definition, type)|
            db_triggers[name] && (db_trigger_warnings[name] = true) && db_triggers[name] == normalize_trigger(name, definition, type)
          end

          migration[:definitions].each do |(name, _, _)|
            db_triggers.delete(name)
            db_trigger_warnings.delete(name)
          end

          migration_trigger_builders << migration[:builder]
        end

        # db_triggers.to_a.sort_by{ |t| (t.first + 'a').sub(/\(/, '_') }.each do |(name, definition)|
        #   if db_trigger_warnings[name]
        #     stream.puts "  # WARNING: generating adapter-specific definition for #{name} due to a mismatch."
        #     stream.puts "  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/"
        #   else
        #     stream.puts "  # no candidate create_trigger statement could be found, creating an adapter-specific one"
        #   end
        #   if definition =~ /\n/
        #     stream.print "  execute(<<-SQL)\n#{definition.rstrip}\n  SQL\n\n"
        #   else
        #     stream.print "  execute(#{definition.inspect})\n\n"
        #   end
        # end

        migration_trigger_builders.each { |builder| stream.print "#{builder.to_ruby('  ', false)}\n\n" }
      end
    end
  end
end

ActiveRecord::SchemaDumper.prepend HairTrigger::SchemaDumper::TrailerWithTriggersSupportExtension
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend HairTrigger::AdapterExtension
