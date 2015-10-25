require 'travis/exceptions/adapter/logger'
require 'travis/exceptions/adapter/raven'

module Travis
  module Exceptions
    module Adapter
      def self.adapters_for(config, env, logger)
        consts = [Logger]
        consts << Raven if config[:sentry] && config[:sentry][:dsn]
        consts.map { |const| const.new(config, env, logger) }
      end
    end
  end
end
