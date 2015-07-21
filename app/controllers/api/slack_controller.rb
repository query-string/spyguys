module Api
  class SlackController < BaseController
    def create
      image        = Image.find(params[:image_id])

      slack_client = Slack::Notifier.new ENV["WEBHOOK_URL"], username: "higuys"
      attachments  = {
        image_url:   image.imgx_url,
        author_icon: "https://brandfolder.com/api/favicon/icon?size=18&domain=www.slack.com",
        color:       "#439FE0"
      }

      attachments.merge!(author_name: image.status_nickname) if image.status_nickname.present?
      attachments.merge!(text: image.status_message) if image.status_message.present?
      slack_client.ping DateTime.now.in_time_zone.to_s,
                        icon_emoji: ":ghost:",
                        attachments: [attachments]

      respond_with_success code: "OK"
    end
  end
end
