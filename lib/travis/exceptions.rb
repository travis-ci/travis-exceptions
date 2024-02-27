# frozen_string_literal: true

require 'travis/exceptions/reporter'

module Travis
  class Exceptions
    class << Exceptions
      attr_reader :instance

      def setup(config, env, logger)
        @instance ||= new(config, env, logger).tap do |instance|
          instance.start
        end
      end

      %i[fatal error warning info].each do |level|
        define_method(level) do |error, opts = {}|
          return puts('Exception handling not set up. Call Travis::Exceptions.setup') unless instance

          instance.send(level, error, opts)
        end
      end

      def handle(error, opts = {})
        return puts('Exception handling not set up. Call Travis::Exceptions.setup') unless instance

        instance.handle(error, opts)
      end
    end

    attr_reader :reporter, :queue, :thread

    def initialize(config, env, logger)
      @reporter = Reporter.new(config.to_h, env, logger)
      @queue = Queue.new
    end

    %i[fatal error warning info].each do |level|
      define_method(level) do |error, opts = {}|
        handle(error, opts.merge(level:))
      end
    end

    def handle(error, opts = {})
      queue.push([error, opts])
    end

    def start
      @thread = Thread.new { loop(&method(:process)) }
    end

    private

    def process
      failsafe { reporter.handle(*queue.pop) }
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
