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

      def handle(*args)
        queue.push(args)
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

        def report(args)
          adapters.each do |adapter|
            adapter.handle(*args)
          end
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
