begin
  require 'raven'
rescue LoadError
end

module Travis
  module Exceptions
    module Adapter
      class Raven
        def initialize(config, env, logger)
          ::Raven.configure do |c|
            c.dsn    = config[:sentry][:dsn]
            c.ssl    = config[:ssl] if config[:ssl]
            c.logger = logger
            c.current_environment = env
          end
        end

        def handle(error, meta = {})
          ::Raven.capture_exception(error, extra: meta)
        end
      end
    end
  end
end
