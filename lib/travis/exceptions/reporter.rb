# frozen_string_literal: true

module Travis
  class Exceptions
    class Reporter < Struct.new(:config, :env, :logger)
      require 'travis/exceptions/reporter/logger'
      require 'travis/exceptions/reporter/metrics'
      require 'travis/exceptions/reporter/raven'

      attr_reader :adapters

      def initialize(*)
        super
        @adapters = consts.map { |const| const.new(config, env, logger) }
      end

      def handle(error, opts)
        adapters.each do |adapter|
          adapter.handle(error, normalize(error, opts))
        end
      end

      private

      OPTS = { level: :error, extra: {}, tags: {} }.freeze

      def normalize(error, opts)
        opts = OPTS.merge(opts)
        opts[:level] = error.level                    if error.respond_to?(:level)
        opts[:extra] = opts[:extra].merge(error.data) if error.respond_to?(:data)
        opts[:tags]  = opts[:tags].merge(error.tags)  if error.respond_to?(:tags)
        opts
      end

      def consts
        consts = [Logger]
        consts << Raven   if config[:sentry]  && config[:sentry][:dsn]
        consts << Metrics if config[:metrics] && config[:metrics][:adapter]
        consts
      end
    end
  end
end
