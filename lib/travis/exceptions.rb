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

      def error(error, extra = {})
        handle(error, extra, severity: :error)
      end

      def warn(error, extra = {})
        handle(error, extra, severity: :warning)
      end

      def info(error, extra = {})
        handle(error, extra, severity: :info)
      end

      def handle(error, extra = {}, tags = {})
        return puts('Error reporter not set up. Call Travis::Exceptions.setup') unless reporter
        extra = extra.merge(extra_from(error))
        reporter.handle(error, extra, tags)
      end

      private

        def extra_from(error)
          error.respond_to?(:metadata) ? error.metadata : {}
        end
    end
  end
end
