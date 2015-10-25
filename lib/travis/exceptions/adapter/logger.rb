module Travis
  module Exceptions
    module Adapter
      class Logger < Struct.new(:config, :env, :logger)
        DEBUG = 0

        def handle(error, meta = {})
          logger.error error.message
          logger.error meta.map { |key, value| "#{key}: #{value}" } if meta && meta.any?
          logger.error error.backtrace if logger.level == DEBUG
        end
      end
    end
  end
end
