begin
  require 'raven'
rescue LoadError
end

module Travis
  module Exceptions
    module Adapter
      class Raven < Struct.new(:config, :env, :logger)
        MSGS = {
          error: 'Sending error to Sentry failed: %s'
        }

        class << self
          def setup(config, env, logger)
            ::Raven.configure do |c|
              c.dsn    = config[:sentry][:dsn]
              c.ssl    = config[:ssl] if config[:ssl]
              c.tags   = { environment: env }
              c.current_environment = env
              c.environments = %w(staging production)
            end
          end
        end

        def handle(error, opts = {})
          ::Raven.capture_exception(error, slice(opts, :level, :extra, :tags))
        rescue Exception => e
          log_error(e)
        end

        def slice(hash, *keys)
          hash.select { |key, _| keys.include?(key) }
        end

        def log_error(error)
          logger.error(MSGS[:error] % error.message)
          logger.error(error.backtrace.join("\n"))
        end
      end
    end
  end
end
