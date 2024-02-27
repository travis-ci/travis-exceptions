# frozen_string_literal: true

begin
  require 'travis/metrics'
rescue LoadError
end

module Travis
  class Exceptions
    class Reporter
      class Metrics < Struct.new(:config, :env, :logger)
        MSGS = {
          error: 'Storing metric failed: %s'
        }.freeze

        def handle(_error, opts = {})
          Travis::Metrics.meter(key(opts))
        rescue Exception => e
          log_error(e)
        end

        private

        def key(_error, opts)
          opts = { app: :unknown, level: :error }.merge(opts)
          [:exceptions, opts[:app], opts[:level]].join('.')
        end

        def log_error(error)
          logger.error(MSGS[:error] % error.message)
          logger.error(error.backtrace.join("\n"))
        end
      end
    end
  end
end
