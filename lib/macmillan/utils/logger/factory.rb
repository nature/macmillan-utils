require 'logger'

module Macmillan
  module Utils
    module Logger

      ##
      # A factory class for building logger objects
      #
      # Usage:
      #
      #   require 'macmillan/utils/logger/factory'
      #
      #   Macmillan::Utils::Logger::Factory.build_logger(type, options)
      #
      class Factory

        ##
        # Builds a logger object
        #
        # Opts varies depending on the type of logger object you are creating...
        #
        #   opts for :syslog
        #     :tag      => [String] the name of the syslog tag to use
        #     :facility => [Integer] the 'LOG_LOCALx' syslog facility to use
        #
        #   opts for :logger
        #     :target   => [String, Object] the target for the Logger object
        #
        #   opts for :null
        #     none
        #
        # @param type [Symbol] the logger type, `:logger`, `:syslog` or `:null`
        # @param opts [Hash] options to pass to your logger object
        # @return [Logger] the configured logger object
        #
        def self.build_logger(type = :logger, opts = {})
          case type
          when :syslog then build_syslog_logger(opts)
          when :null   then build_normal_logger(target: '/dev/null')
          else
            build_normal_logger(opts)
          end
        end

        private

        def self.build_syslog_logger(opts)
          require 'syslog-logger'

          ::Logger::Syslog.class_eval do
            alias_method :write, :info
          end

          tag      = opts.fetch(:tag)
          facility = Object.const_get("Syslog::LOG_LOCAL#{opts.fetch(:facility, 0)}")

          ::Logger::Syslog.new(tag, facility)
        end

        def self.build_normal_logger(opts)
          ::Logger.new(opts.fetch(:target, $stdout))
        end
      end
    end
  end
end
