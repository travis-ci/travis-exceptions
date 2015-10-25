require 'thread'
require 'travis/exceptions/adapter'

module Travis
  module Exceptions
    class Reporter < Struct.new(:config, :env, :logger)
      attr_reader :queue, :adapters

      def initialize(*)
        super
        @adapters = Adapter.adapters_for(config, env, logger)
        @queue = Queue.new
      end

      def handle(error)
        queue.push(error)
      end

      def start
        @thread = Thread.new { loop &method(:process) }
      end

      private

        def process
          failsafe do
            report(queue.pop)
          end
        end

        def report(error)
          adapters.each do |adapter|
            adapter.handle(error, metadata_for(error))
          end
        end

        def metadata_for(error)
          error.respond_to?(:metadata) ? error.metadata : {}
        end

        def failsafe
          yield
        rescue Exception => e
          puts '---- FAILSAFE ----'
          puts "Error while handling exception: #{e.message}"
          puts e.backtrace
          puts '------------------'
        end
    end
  end
end
