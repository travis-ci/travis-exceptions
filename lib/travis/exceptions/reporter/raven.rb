begin
  require 'raven'
rescue LoadError
end

module Travis
  class Exceptions
    class Reporter
      class Raven < Struct.new(:config, :env, :logger)
        MSGS = {
          setup: 'Setting up Raven with dsn: %s, env: %s',
          error: 'Sending error to Sentry failed: %s'
        }

        def initialize(*)
          super
          setup
        end

        def handle(error, opts = {})
          ::Raven.capture_exception(error, slice(opts, :level, :extra, :tags))
        rescue Exception => e
          log_error(e)
        end

        private

          def setup
            logger.info(MSGS[:setup] % [strip_password(config[:sentry][:dsn]), env])

            ::Raven.configure do |c|
              c.logger = logger
              c.dsn  = config[:sentry][:dsn]
              c.ssl  = config[:ssl] if config[:ssl]
              c.tags = { environment: env }
              c.current_environment = env.to_s
              c.environments = %w(staging production)
              c.excluded_exceptions.clear
            end
          end

          def strip_password(dsn)
            tokens = dsn.scan(%r(https://(.+):(.+)@[\w]+.[\w]+.[\w]+/[\d]+)).flatten
            tokens.inject(dsn) { |dsn, token| dsn.sub(token, 'REDACTED') }
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
