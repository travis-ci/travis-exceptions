# frozen_string_literal: true

require 'raven'

module Travis
  class Exceptions
    class Sidekiq < Struct.new(:env, :logger)
      def call(worker, message, queue)
        yield
      rescue Exception => e
        logger&.error(e.to_s)
        report(e, queue:, worker: worker.to_s, env:) if retried?(message)
        raise
      end

      private

      def retried?(message)
        message.key?('retry_count')
      end

      def report(error, extra)
        Raven.capture_exception(error, extra:)
      end
    end
  end
end
