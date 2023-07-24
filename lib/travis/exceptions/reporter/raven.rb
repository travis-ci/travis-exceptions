# frozen_string_literal: true

require 'sentry-ruby'

module Travis
  class Exceptions
    class Reporter
      class Raven < Struct.new(:config, :env, :logger)
        MSGS = {
          setup: 'Setting up Raven with dsn: %s, env: %s',
          error: 'Sending error to Sentry failed: %s'
        }.freeze

        def initialize(*)
          super
          setup
        end

        def handle(error, opts = {})
          ::Sentry.capture_exception(error, level: opts[:level], extra: opts[:extra], tags: opts[:tags])
        rescue Exception => e
          log_error(e)
        end

        private

        def setup
          logger.info(format(MSGS[:setup], strip_password(config[:sentry][:dsn]), env))

          ::Sentry.init do |c|
            c.logger = logger
            c.dsn  = config[:sentry][:dsn]
            c.ssl  = config[:ssl] if config[:ssl]
            c.environment = env.to_s
            c.enabled_environments = %w[staging production]
            c.excluded_exceptions.clear
          end

          Sentry.set_tags environment: env
        end

        def strip_password(dsn)
          tokens = dsn.scan(%r{https://(.+):(.+)@\w+.\w+.\w+/\d+}).flatten
          tokens.inject(dsn) { |dsnval, token| dsnval.sub(token, 'REDACTED') }
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
