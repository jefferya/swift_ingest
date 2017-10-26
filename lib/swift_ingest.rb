require 'swift_ingest/version'
require 'swift_ingest/ingestor'
require 'active_support'
require 'active_support/core_ext'

module SwiftIngest
  DEFAULTS = {
    tenant: 'tester',
    username: 'test:tester',
    password: 'testing',
    auth_url: 'http://www.example.com:8080/auth/v1.0',
    project: 'ERA',
    project_name: 'ERA',
    project_domain_name: 'default'
  }.freeze
end
