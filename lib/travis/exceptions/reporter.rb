require 'thread'
require 'travis/exceptions/adapter'

module Travis
  module Exceptions
    class Reporter < Struct.new(:config, :env, :logger)
      OPTIONS = { level: :error, extra: {}, tags: {} }

      class << self
        def setup(config, env, logger)
          Adapter.adapters_for(config).each do |const|
            const.setup(config, env, logger) if const.respond_to?(:setup)
          end
        end
      end

      attr_reader :adapters, :queue

      def initialize(*)
        super
        @adapters = Adapter.adapters_for(config).map { |const| const.new(config, env, logger) }
        @queue = Queue.new
      end

      def handle(error, opts = {})
        queue.push([error, opts])
      end

      def start
        @thread = Thread.new { loop &method(:process) }
      end

      private

        def process
          failsafe do
            error, opts = *queue.pop
            report(error, normalize(error, opts))
          end
        end

        def report(error, opts)
          adapters.each do |adapter|
            adapter.handle(error, opts)
          end
        end

        def normalize(error, opts)
          opts = OPTIONS.merge(opts)
          opts[:level] = error.level                    if error.respond_to?(:level)
          opts[:extra] = opts[:extra].merge(error.data) if error.respond_to?(:data)
          opts[:tags]  = opts[:tags].merge(error.tags)  if error.respond_to?(:tags)
          opts
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
