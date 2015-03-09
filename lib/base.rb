require 'redis'

module FriendFinder
  module Base
    module Methods
      def redis
        @@redis ||= redis_connection
      end

      private

      def redis_connection
        Redis.new
      end
    end

    def self.included(klass)
      klass.extend(Methods)
      klass.send(:include, Methods)
    end
  end
end
