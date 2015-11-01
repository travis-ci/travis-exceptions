require 'travis/exceptions/adapter/logger'
require 'travis/exceptions/adapter/metrics'
require 'travis/exceptions/adapter/raven'

module Travis
  module Exceptions
    module Adapter
      def self.adapters_for(config)
        consts = [Logger]
        consts << Raven   if config[:sentry]  && config[:sentry][:dsn]
        consts << Metrics if config[:metrics] && config[:metrics][:adapter]
        consts
      end
    end
  end
end
