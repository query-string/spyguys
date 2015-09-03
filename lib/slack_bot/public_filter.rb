class SlackBot
  class PublicFilter < Filter
    include SlackBot::Environment

    def gate_text
      message
    end

    def gate_source
      "##{target}"
    end

    def proper_target_defined?
      # If channel is a target channel
      # If first part of messge – is a username
      # If requested user id is equal to bot user id
      source == target_channel_id && recipient_user =~ regex && recipient_user_id == bot_user.id
    end

    private

    def splitted_text
      text.split(":")
    end

    def message
      splitted_text[1].to_s.strip
    end

    def recipient_user
      splitted_text[0]
    end

    def recipient_user_id
      recipient_user.match(regex).captures.join
    end

    def target_channel_id
      realtime.find_channel(target).try(:id)
    end
  end
end