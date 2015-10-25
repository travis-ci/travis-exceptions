require 'travis/exceptions/reporter'

module Travis
  module Exceptions
    class << self
      attr_reader :reporter

      def setup(config, env, logger)
        @reporter = Reporter.new(config.to_h, env, logger)
        reporter.start
        reporter
      end

      def handle(error)
        reporter ? reporter.handle(error) : puts("Error reporter not set up. Call Travis::Exceptions.setup")
      end
    end
  end
end
