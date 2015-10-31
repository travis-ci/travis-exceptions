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
            c.tags   = { environment: env }
            c.current_environment = env
            c.environments = %w(staging production)
          end
        end

        def handle(error, extra = {}, tags = {})
          ::Raven.capture_exception(error, extra: extra, tags: tags)
        end
      end
    end
  end
end
