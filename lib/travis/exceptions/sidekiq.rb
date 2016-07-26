require 'raven'

module Travis
  class Exceptions
    class Sidekiq < Struct.new(:env, :logger)
      def call(worker, message, queue)
        yield
      rescue Exception => error
        logger.error(error.to_s) if logger
        report(error, queue: queue, worker: worker.to_s, env: env) if retried?(message)
        raise
      end

      private

        def retried?(message)
          message['retry_count'].to_i >= 1
        end

        def report(error, extra)
          Raven.capture_exception(error, extra: extra)
        end
    end
  end
end
