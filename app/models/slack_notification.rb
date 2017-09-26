class SlackNotification < ApplicationRecord
  class << self
    def notify_attendees(attendees_name_list, team_list)
      if Rails.env.development?
        client = SlackNotify::Client.new(
          webhook_url: ENV['slack_webhook_url'],
          channel: '#random',
          username: 'WanderLunch',
          link_names: turn_on_mention
        )
        client.notify(message(attendees_name_list, team_list))
      end
    end

    private

    def turn_on_mention
      1
    end

    def message(attendees_name_list, team_list)
      message = ["@here "]
      attendees_name_list.each_with_index do |attendee_name, idx|
        if attendee_name.length < 10
          space_num = 10 - attendee_name.length
          space_num.times {
            attendee_name.concat(" ")
          }
        end
        message << "*Name* : #{attendee_name} *Group* : #{team_list[idx]}"
      end
      return message.join("\n")
    end
  end
end
