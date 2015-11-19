require 'travis/exceptions/reporter'

module Travis
  module Exceptions
    class << self
      attr_reader :reporter

      def setup(config, env, logger)
        Reporter.setup(config, env, logger)
        @reporter = Reporter.new(config.to_h, env, logger)
        reporter.start
        reporter
      end

      [:fatal, :error, :warning, :info].each do |level|
        define_method(level) do |error, opts = {}|
          handle(error, opts.merge(level: level))
        end
      end

      def handle(error, opts = {})
        return puts('Error reporter not set up. Call Travis::Exceptions.setup') unless reporter
        reporter.handle(error, opts)
      end
    end
  end
end
