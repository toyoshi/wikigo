module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # #110: identifies streams over the app's own Session records (the
    # signed session_id cookie), replacing Devise/Warden identification.
    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.current_user = session.user
        end
      end
  end
end
