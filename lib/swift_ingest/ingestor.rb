require 'swift_ingest/version'
require 'openstack'
require 'mysql2'

class SwiftIngest::Ingestor

  attr_reader :swift_connection, :project

  def initialize(connection = {})
    extra_opt = { auth_method: 'password',
                  service_type: 'object-store' }
    options = SwiftIngest::DEFAULTS.merge(connection).merge(extra_opt)
    options[:api_key] = options.delete :password

    @swift_connection = OpenStack::Connection.create(options)
    @project = connection[:project]

    # connect to the database
    @dbcon = if ENV['DB_HOST'] && ENV['DB_USER'] && ENV['DB_PASSWORD'] && ENV['DB_DATABASE']
               Mysql2::Client.new(host: ENV['DB_HOST'],
                                  username: ENV['DB_USER'],
                                  password: ENV['DB_PASSWORD'],
                                  database: ENV['DB_DATABASE'])
             end
  end

  # ToDo: refactor
  # (a) to avoid reopening the container each time
  # (b) if not extension on the filename then potentially fails if base name contains a '.'
  def get_file_from_swit(file_name, swift_container)
    deposited_file = nil
    file_base_name = File.basename(file_name, '.*')
    container = swift_connection.container(swift_container)
    deposited_file = container.object(file_base_name) if container.object_exists?(file_base_name)
    deposited_file
  end

  def lookup(id, swift_container)
    container = swift_connection.container(swift_container)
    container.object(id) if container.object_exists?(id)
  end

  def deposit_file(file_name, swift_container, custom_metadata = {})
    deposit_file(File.basename(file_name, '.*'), file_name, swift_container, custom_metadata)
  end

  def deposit(id, file_name, swift_container, custom_metadata = {})
    checksum = Digest::MD5.file(file_name).hexdigest
    container = swift_connection.container(swift_container)

    # Add swift metadata with in accordance to AIP spec:
    # https://docs.google.com/document/d/154BqhDPAdGW-I9enrqLpBYbhkF9exX9lV3kMaijuwPg/edit#
    metadata = {
      project: @project,
      project_id: id,
      promise: 'bronze',
      aip_version: '1.0'
    }.merge(custom_metadata)

    # ruby-openstack wants all keys of the metadata to be named like
    # "X-Object-Meta-{{Key}}" so update them
    metadata.transform_keys! { |key| "X-Object-Meta-#{key}" }

    if container.object_exists?(id)
      # temporary solution until fixed in upstream:
      # for update: construct hash for key/value pairs as strings,
      # and metadata as additional key/value string pairs in the hash
      headers = { 'etag' => checksum,
                  'content-type' => 'application/x-tar' }.merge(metadata)
      deposited_file = container.object(id)
      deposited_file.write(File.open(file_name), headers)
    else
      # for creating new: construct hash with symbols as keys, add metadata as a hash within the header hash
      headers = { etag: checksum,
                  content_type:  'application/x-tar',
                  metadata: metadata }
      deposited_file = container.create_object(id, headers, File.open(file_name))
    end

    return deposited_file unless @dbcon

    # update db with deposited file info
    @dbcon.query("INSERT INTO archiveEvent(project, container, ingestTime, \
                  objectIdentifier, objectChecksum, objectSize) \
                  VALUES('#{@project}', '#{swift_container}', now(), '#{id}', '#{checksum}', \
                  '#{File.size(file_name)}')")
    custom_metadata.each do |key, value|
      @dbcon.query("INSERT INTO customMetadata(eventId, propertyName, propertyValue) \
                    VALUES(LAST_INSERT_ID(), '#{key}', '#{value}' )")
    end

    deposited_file
  end

end
