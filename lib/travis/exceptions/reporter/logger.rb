module Travis
  class Exceptions
    class Reporter
      class Logger < Struct.new(:config, :env, :logger)
        DEBUG = 0

        def handle(error, opts = {})
          level = opts.delete(:level) || :error
          log level, error.message
          log level, to_pairs(opts[:tags])  if opts[:tags]
          log level, to_pairs(opts[:extra]) if opts[:extra]
          log level, error.backtrace
        end

        private

          def to_pairs(data)
            (data || {}).map { |key, value| "#{key}: #{value}" }.join(' ')
          end

          def log(level, lines)
            Array(lines).each do |line|
              logger.send(level, line) unless line.nil? || line.empty?
            end
          end
      end
    end
  end
end
