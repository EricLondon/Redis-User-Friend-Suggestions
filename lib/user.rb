module FriendFinder
  class User
    include Base
    include Friend

    def initialize(options = {})
      @data = options ||= {}
      fail 'Options must be a Hash' unless options.is_a?(Hash)

      # dynamically add a few methods
      [:id, :first_name, :last_name].each do |meth|
        unless self.class.method_defined?(meth)
          self.class.send(:define_method, meth) do
            @data[meth]
          end
        end
      end
    end

    def create!
      options = default_options.merge(@data)
      redis.hmset(to_key, options.flatten)
      redis.sadd(self.class.id_key, id)
    end

    def default_options
      random_name
    end

    def random_name
      @@names ||= load_random_names
      { first_name: @@names[:first].sample, last_name: @@names[:last].sample }
    end

    def load_random_names
      ret = { first: [], last: [] }
      File.readlines('names.txt').each do |line|
        first_name, last_name = line.strip.split(/\s/)
        ret[:first] << first_name
        ret[:last] << last_name
      end
      ret
    end

    def to_key
      fail 'Id required' if id.nil?
      "#{self.class.name}:#{id}"
    end

    def load!
      data = redis.hgetall(to_key)
      data = Hash[data.map { |(k, v)| [k.to_sym, v] }]
      @data.merge! data
      self
    end

    def puts_output
      puts "ID:\t\t#{id}"
      puts "first name:\t#{first_name}"
      puts "last name:\t#{last_name}"
      puts
    end

    #
    # Class methods
    #

    def self.id_key
      "#{name}:ID"
    end

    def self.random_user_id
      redis.srandmember id_key
    end

    def self.create_users!(how_many = 1_000)
      fail 'How many must be an Integer' unless how_many.respond_to?(:times)
      how_many.times do |i|
        new(id: i + 1).create!
      end
    end

    def self.all_ids
      redis.smembers id_key
    end
  end
end
