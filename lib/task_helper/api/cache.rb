module TaskHelper
  module API
    class Cache
      def initialize(limit: 10)
        @limit = limit
        @calls = []
      end

      def get(**args)
        new_call = Call.new(args)
        cached_call = @calls.find { |call| call == new_call }
        if cached_call
          cached_call.run
        else
          @calls << new_call
          sort_calls.pop if @calls.size > @limit
          new_call.run
        end
      end

      private

      def sort_calls
        @calls.sort! { |x, y| y.time <=> x.time }
      end
    end
  end
end
