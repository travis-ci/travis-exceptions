module Travis
  module Exceptions
    module Adapter
      class Logger < Struct.new(:config, :env, :logger)
        DEBUG = 0

        def handle(error, meta = {}, tags = {})
          severity = tags.delete(:severity) || :error
          log severity, error.message
          log severity, tags.map { |key, value| "#{key}: #{value}" } if tags && tags.any?
          log severity, meta.map { |key, value| "#{key}: #{value}" } if meta && meta.any?
          log severity, error.backtrace if logger.level == DEBUG
        end

        private

          def log(severity, lines)
            Array(lines).each do |line|
              logger.send(severity, line)
            end
          end
      end
    end
  end
end
