module FriendFinder
  module Main
    extend self

    def execute
      options = CommandLine.options

      case options[:action]

      when :create_users
        User.create_users!

      when :create_friends
        User.create_friends!

      when :suggest_friend
        User.suggest_friend

      else
        fail 'Action required'
      end
    end
  end
end
