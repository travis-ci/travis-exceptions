require 'travis/exceptions/reporter'

module Travis
  module Exceptions
    class << self
      attr_reader :reporter

      def setup(context)
        @reporter = Reporter.new(context.config.to_h, context.env, context.logger)
        reporter.start
        reporter
      end

      def handle(error)
        reporter.handle(error)
      end
    end
  end
end
