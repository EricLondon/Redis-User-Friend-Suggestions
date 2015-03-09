require 'optparse'

module FriendFinder
  module CommandLine
    extend self

    def options
      @options ||= parse_options
    end

    def parse_options
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

        opts.on('--create-users', 'Create users') do |_v|
          options[:action] = :create_users
        end

        opts.on('--create-friends', 'Create friends') do |_v|
          options[:action] = :create_friends
        end

        opts.on('--suggest-friend', 'Suggest friend') do |_v|
          options[:action] = :suggest_friend
        end
      end.parse!
      options
    end
  end
end
