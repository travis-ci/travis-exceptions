# frozen_string_literal: true

require 'travis/exceptions'

Raven.configure do |config|
  config.silence_ready = true
end

RSpec.configure do |c|
  c.mock_with :mocha
  # c.before { Raven.stubs(:capture_exception) }
end
