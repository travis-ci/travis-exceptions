begin
  require 'raven'
rescue LoadError
end

module Travis
  module Exceptions
    module Adapter
      class Raven
        attr_reader :logger

        def initialize(config, env, logger)
          @logger = logger

          ::Raven.configure do |c|
            c.dsn    = config[:sentry][:dsn]
            c.ssl    = config[:ssl] if config[:ssl]
            c.logger = logger
            c.tags   = { environment: env }
            c.current_environment = env
            c.environments = %w(staging production)
          end
        end

        def handle(error, extra = {}, tags = {})
          ::Raven.capture_exception(error, extra: extra, tags: tags)
        rescue Exception => e
          logger.error("Sending error to Sentry failed: #{e.message}")
          logger.error(e.backtrace.join("\n"))
        end
      end
    end
  end
end
