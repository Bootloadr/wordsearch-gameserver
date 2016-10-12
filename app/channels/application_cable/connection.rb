module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      REDIS.set("user_#{cookies.signed[:player_id]}", cookies.signed[:game_id])
    end
    protected
      def find_verified_user
        if current_user = cookies.signed[:player_id]
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
