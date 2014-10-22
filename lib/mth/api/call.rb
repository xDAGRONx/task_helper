module MTH
  module API
    class Call
      MissingAPIKey = Class.new(StandardError)

      attr_reader :route, :params, :time
      protected :route, :params

      def initialize(route:, params: {}, timeout: 314, time: Time.now)
        @params = { rest_api_key: API.rest_api_key }.merge(params)
        if @params[:rest_api_key].nil?
          raise MissingAPIKey, "Rest API key not provided. " \
            "Either pass it as a param or use " \
            "'MTH::API.rest_api_key = key' " \
            "to set it for all future calls."
        end
        @route = "#{BASE_URL}/#{route}"
        @timeout = timeout
        @time = time
        set_end_time
      end

      def run
        @time = Time.now
        if expired? || !@result
          set_end_time
          @result = HTTParty.get(@route, @params).parsed_response
        else
          @result
        end
      end

      def expired?
        @end_time < Time.now
      end

      def ==(other_call)
        @route == other_call.route && @params == other_call.params
      end

      private

      def set_end_time
        @end_time = @time + @timeout
      end
    end
  end
end
