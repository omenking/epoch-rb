require 'httparty'
require 'ostruct'
require 'epoch_api/version'

module EpochApi
  class UnknownRoom         < StandardError; end
  class Unauthorized        < StandardError; end
  class UnknownResponseCode < StandardError; end
  class UsernameTooLong     < StandardError; end

  class Client
    include HTTParty

    base_uri 'https://3poch.com/api/v1/rooms'
    format :json

    def initialize token, options={}
      @token = token
			self
    end

    def message room_token, from, message, options = {color: 'yellow', notify: false}
			err_msg = "Username #{from} is `#{from.length} characters long. Limit is 15'" 
			raise UsernameTooLong, err_msg if from.length > 15

      response = self.class.put "/#{room_id}/message",
        query: { auth_token: @token },
        body: {
          from:    from,
          message: message,
          color:   options[:color],
          notify:  options[:notify] ? 1 : 0 }

      _response response
    end

    def topic new_topic, options = {from: 'API'}

      response = self.class.put "/#{room_id}/topic",
        query: { auth_token: @token },
        body: {
          from: options[:from],
          topic: new_topic}

      _response response
    end

		def _response response
			case response.code
				when 200 then response.body
				when 404 then raise UnknownRoom        , "Unknown room: `#{room_id}'"
				when 401 then raise Unauthorized       , "Access denied to room `#{room_id}'"
				else;         raise UnknownResponseCode, "Unexpected #{response.code} for room `#{room_id}'"
			end
		end
  end
end
