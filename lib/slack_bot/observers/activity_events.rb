class SlackBot
  module Observers
    class ActivityEvents < SlackBot::Observers::Bus
      def command_channel
        "activity_event"
      end

      def hello_message
        "PG Listening for activity events..."
      end
    end
  end
end