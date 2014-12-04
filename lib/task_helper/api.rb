module TaskHelper
  module API
    BASE_URL = 'https://mytaskhelper.com'

    class << self
      attr_accessor :rest_api_key
    end

    def get(args)
      @cache.get(args)
    end

    def set_cache(args={})
      @cache = Cache.new(args)
    end

    def self.extended(base)
      base.set_cache
    end

    extend self
  end
end
