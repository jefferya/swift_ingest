require 'spec_helper'

RSpec.describe SwiftIngest do
  it 'has a version number' do
    expect(SwiftIngest::VERSION).not_to be nil
  end
end
