class SlackBot
  class RealtimeEvent < Event
    attr_reader :realtime, :client, :data

    def initialize(attributes, &callback)
      @client = attributes.fetch(:realtime).client
      super
    end

    private

    def hello_message
      "Listening chat..."
    end

    def listen
      client.on :message do |data|
        @data = data.to_hashugar
        callback.call type
      end
      client.start
    end

    def type
      realtime.channel_ids.include?(data.channel) ? "Public" : "Private"
    end
  end
end
