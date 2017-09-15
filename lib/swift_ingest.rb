require 'swift_ingest/version'
require 'swift_ingest/ingestor'
require 'active_support'
require 'active_support/core_ext'

module SwiftIngest

  DEFAULTS = {
      auth_version: 'v1.0',
      tenant: 'tester',
      username: 'test:tester',
      password: 'testing',
      endpoint: 'http://localhost:8080',
      container: 'ERA'
  }.freeze

end
