require "slack_bot/environment"
require "slack_bot/realtime"

require "slack_bot/observers/observer"
require "slack_bot/observers/realtime_observer"
require "slack_bot/observers/bus_observer"
require "slack_bot/filter/filter"
require "slack_bot/filter/public_filter"
require "slack_bot/filter/private_filter"
require "slack_bot/filter/slash_filter"

require "slack_bot/forwarder_powerball"
require "slack_bot/forwarder"
require "slack_bot/sender"

# @TODO: Empty message error
# @TODO: Show us command doesn't work
# @TODO: Send messages other the realtime instance
# @TODO: Attributes :realtime and :realtime_message might be a part of Forwarder class
# @TODO: Remove environment

class SlackBot
  attr_reader :realtime, :target

  def initialize(target = "general")
    @target   = target
    @realtime = SlackBot::Realtime.new
  end

  def start
    r = observer_realtime
    b = observer_bus
    r.join
    b.join
  end

  def observer_realtime
    observer = SlackBot::RealtimeObserver.new(realtime_attributes)
    observer.on { |filter_type| handler filter_type, observer }
  end

  def observer_bus
    observer = SlackBot::BusObserver.new(realtime_attributes)
    observer.on { handler "Slash" }
  end

  private

  def handler(type, realtime_event = nil)
    filter_attr = realtime_event.present? ? realtime_attributes.merge(realtime_event: realtime_event) : realtime_attributes
    filter      = "SlackBot::#{type}Filter".constantize.new filter_attr

    reply SlackBot::Forwarder.new(filter) if filter.proper_target_defined?
  end

  def realtime_attributes
    {
      realtime: realtime,
      target:   target
    }
  end

  def reply(forwarder)
    case forwarder.flag
      when :notice
        SlackPost.execute forwarder.destination, forwarder.event
      when :users
        # @TODO: Extract to the Forwarder class as well
        SlackPostPhoto.execute forwarder.destination, forwarder.local_users.first[:user].last_image if forwarder.local_users.any?
      end
  end
end
