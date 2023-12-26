# frozen_string_literal: true

class ApexManager
  DEFAULT_DIR = 'salesforce/apex'
  SLEEP_FOR_ASYNC_REQ = 2

  def initialize(files, dir = DEFAULT_DIR)
    @files = files
    @dir = dir
  end

  def deploy
    each_files do |file|
      if file.sfid.present?
        log(:update, file)
        update(file.type, file.sfid, file.content)
      else
        log(:create, file)
        create(file.type, file.content)
      end
    end
  end

  def delete
    each_files do |file|
      log(:delete, file)

      tooling.destroy!(file.type, file.sfid) if file.sfid.present?
    end
  end

  def deactivate_triggers
    each_files do |file|
      next if file.type != 'ApexTrigger'

      log(:deactivate, file)

      body = file.content.gsub(/^  /, '//  ')
      update(file.type, file.sfid, body)
    end
  end

  private

  attr_reader :files, :dir

  # rubocop:disable Style/OpenStructUse
  def each_files
    files.each do |filename|
      name = File.basename(filename, '.*')
      type = "Apex#{filename.ends_with?('.tgr') ? 'Trigger' : 'Class'}"
      yield(
        OpenStruct.new(
          type:,
          name:,
          content: File.read(File.join(dir, filename)),
          sfid:    fetch_sfid(type, name)
        )
      )
    end
  end
  # rubocop:enable Style/OpenStructUse

  def fetch_sfid(type, name)
    tooling.query("select Id from #{type} where Name = '#{name}'").first&.Id
  end

  def create(type, content)
    params = case type
             when 'ApexClass'
               { Body: content }
             when 'ApexTrigger'
               { Body: content, TableEnumOrId: content.scan(/ on (\w+) /).first.first }
             end
    tooling.create!(type, params)
  end

  def update(type, entity_id, body)
    timestamp = Time.current.in_time_zone('Tokyo').strftime('%Y%m%d%H%M%S')
    container_id = tooling.create!('MetadataContainer', { Name: "FCWebContainer-#{timestamp}" })
    tooling.create!("#{type}Member", MetaDataContainerId: container_id, ContentEntityId: entity_id, Body: body)
    request_id = tooling.create!('ContainerAsyncRequest', IsCheckOnly: false, MetadataContainerId: container_id)

    wait_for_complete(request_id)
  end

  # :nocov:
  def wait_for_complete(request_id)
    loop do
      state = tooling.find('ContainerAsyncRequest', request_id).State
      logger.debug "#{request_id}: #{state}"
      break if %w[Completed Error Failed].include?(state)

      # :reek:
      sleep SLEEP_FOR_ASYNC_REQ
      # :reek:
    end
  end
  # :nocov:

  def tooling
    @tooling ||= RestforceFactory.new_tooling
  end

  def logger
    Rails.logger
  end

  def log(action, file)
    logger.debug("#{action}(#{file.type}): #{file.name}")
  end
end
