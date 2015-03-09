module FriendFinder
  module Friend
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def friends_key
        fail 'Id required' if id.nil?
        "#{self.class.name}:#{id}:Friends"
      end

      def friends_size
        redis.scard friends_key
      end

      def has_friend?(friend_id)
        redis.sismember friends_key, friend_id
      end

      def friends_create!(friend_id)
        return false if has_friend?(friend_id)
        redis.sadd friends_key, friend_id
      end

      def friend_ids
        redis.smembers friends_key
      end
    end

    module ClassMethods
      def create_friends!(how_many_each = 100)
        fail 'How many each must be an Integer' unless how_many_each.respond_to?(:times)

        all_ids.each do |id|
          user = new(id: id).load!

          while user.friends_size < how_many_each
            user.friends_create!(random_user_id)
          end
        end
      end

      def suggest_friend(user_id = nil)
        user_id ||= random_user_id
        fail 'User id required' if user_id.nil?

        user = new(id: user_id).load!

        # output
        puts 'Randomly selected user:'
        user.puts_output

        # get friends of friends
        friend_ids = user.friend_ids
        friends_of_friends = []
        friend_ids.each do |friend_id|
          friends_of_friends.push(*new(id: friend_id).load!.friend_ids)
        end

        fail 'No friends of friends found' if friends_of_friends.empty?

        # group/count
        friend_counts = friends_of_friends.inject(Hash.new(0)) { |h, i| h[i] += 1; h }

        # sort
        friend_counts = Hash[friend_counts.sort_by { |_k, v| -v }]

        # remove existing
        friend_counts.reject! { |k, _v| friend_ids.include?(k) }

        # get first friend suggestion
        suggested_friend_id, suggested_friend_count = friend_counts.first

        suggested_friend = new(id: suggested_friend_id).load!

        # output
        puts 'Suggested friend:'
        suggested_friend.puts_output
        puts "Number of friends with #{suggested_friend.first_name}: #{suggested_friend_count}"
      end
    end
  end
end
