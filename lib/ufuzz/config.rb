module UFuzz
  class Config
    extend Options
    include Validator
    attr_accessor :store, :monitor, :session, :logger
    
    def default_options
      { 
        :request          => nil,
        :logging          => { :text => true },
        :verbose          => 2,
        :connect_timeout  => 2,
        :read_timeout     => 10,
        :write_timeout    => 10,
        :non_block        => true,
        :nonblock         => true,
        :chunk_size       => UFuzz::DEFAULT_CHUNK_SIZE,
        :retry_limit      => UFuzz::DEFAULT_RETRY_LIMIT,
        :traversal_match  => UFuzz::DEFAULT_TRAVERSAL_MATCH,
        :extra_param      => 't',
        :csrf_token_regex => /csrfmiddlewaretoken/,
        :detect_delay     => 5,
        #:fuzz_encoding    => { :url => true },
        :thread_count     => 1
      }
    end
    
    def options
      { }
    end
    
    def initialize(opts)
      @store = OpenStruct.new(default_options.merge(options.merge(opts)))
      validate(self)
    end
    
    def method_missing(meth, *args, &block)
      @store.send(meth, *args)
    rescue
      nil
    end
    
    def create_request
      "UFuzz::#{@store.app.camelize}::Request".safe_constantize.new(@store.request)
    rescue
      nil
    end
    
    def create_connection
      "UFuzz::#{@store.app.camelize}::Connection".safe_constantize.new(self)
    rescue
      nil
    end
    
    def create_monitor
      @monitor ||= "#{@store.module.camelize}Monitor".safe_constantize.new(self)
    rescue => e
      UFuzz::Monitor.new(self)
    end
    
    def create_session
      @session ||= "#{@store.module.camelize}Session".safe_constantize
      @session.new(self)
    rescue => e
      UFuzz::Http::Session.new(self)
    end
    
    def create_logger
      @logger ||= Logger.instance
    end
    
    def create_testcase
      test_set = @store.tests || [ 'buffer', 'integer', 'fmt', 'path', 'cmd', 'sqli', 'xxe' ]

      tests = test_set.map do |t|
        "UFuzz::#{t.camelize}Test".safe_constantize.new(:monitor => create_monitor)
      end
      
      TestCaseChain.new(*tests)
    end
    
    # class methods
    
    def self.create(command_line)
      opts = parse_options(command_line)
      @@instance = "#{opts[:module].camelize}Config".safe_constantize.new(opts)
    end
    
    def self.instance
      @@instance
    end
  end
end