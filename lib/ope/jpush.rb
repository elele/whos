module OPE
  module Jpush
    # 发送推送
    def send_payload payload
      begin
        push_client = JPush::JPushClient.new '7029d8cf9866a9dbe132a9f2', 'e192eb76cc4d8c0056b17581'
        push_result = push_client.sendPush payload
          # if platform == 'ios_beta'
          #   push_client = JPush::JPushClient.new JpushConfig['beta_app_key'], JpushConfig['beta_master_secret']
          #   push_result = push_client.sendPush payload
          # elsif platform == 'all'
          #   push_client = JPush::JPushClient.new JpushConfig['beta_app_key'], JpushConfig['beta_master_secret']
          #   push_result = push_client.sendPush payload
          #   push_client = JPush::JPushClient.new JpushConfig['release_app_key'], JpushConfig['release_master_secret']
          #   push_result = push_client.sendPush payload
          # else
          #   push_client = JPush::JPushClient.new JpushConfig['release_app_key'], JpushConfig['release_master_secret']
          #   push_result = push_client.sendPush payload
          # end
      rescue Exception => ex
        Rails.logger.debug ex.inspect
        # PushException.create!(exception: ex.inspect, push: self, platform: platform, result: push_result)
      end
    end

    def notification_payload platform
      platform ||= push_platform
      payload = JPush::PushPayload.build(
          audience: push_audiences,
          platform: platform,
          options: JPush::Options.build(
              apns_production: self.whos_user_device.production #Rails.env.production? || Rails.env.beta?
          ),
          notification: JPush::Notification.build(
              alert: push_message,
              ios: JPush::IOSNotification.build(
                  alert: push_message,
                  sound: 'who.caf',
                  extras: nil,
                  #title: "ios notification title test",
                  badge: 0,
                  content_available: self.options,
                  category: "whos"
              #extras: options
              )
          )
      )
      payload
    end

    def message_payload
      payload = JPush::PushPayload.build(
          audience: push_audiences,
          platform: push_platform,
          options: JPush::Options.build(
              apns_production: self.whos_user_device.production #Rails.env.production? || Rails.env.beta?
          ),
          message: JPush::Message.build(
              msg_content: push_message,
              platform: JPush::Platform.all,
              #title: "message title test",
              #content_type: "message content type test",
              extras: self.options,
              options: JPush::Options.build(
                  sendno: self.id,
                  time_to_live: 0,
                  apns_production: self.whos_user_device.production #Rails.env.production? || Rails.env.beta?
              )
          )
      )
      payload
    end

    def push_message
      case self.message_type
        when 3
          "来自 Who's 机器人"
        when 0, 2
          "来自 #{self.user.user_name}"
        when 1
          "#{self.user.user_name} @位置"
      end
    end

    def push_audiences
      if self.whos_user_device
        audience = JPush::Audience.build(registration_id: [self.whos_user_device.registration_id])
      else
        audience = JPush::Audience.all
      end
    end

    def ios_platform?
      # self.receiver && self.receiver.app_platform && self.receiver.app_platform.downcase.match(/ios/)
      self.whos_user_device && self.whos_user_device.model && self.whos_user_device.model.downcase.match(/ios/)
    end

    def android_platform?
      self.whos_user_device && self.whos_user_device.model && self.whos_user_device.model.downcase.match(/android/)
      # self.receiver && self.receiver.app_platform && self.receiver.app_platform.downcase.match(/android/)
    end

    def no_platform?
      self.receiver && !self.receiver.app_platform.present?
    end

    def push_platform
      # if self.receiver
      #   if android_platform?
      #     android_platform = JPush::Platform.new
      #     android_platform.android = true
      #     return android_platform
      #   elsif ios_platform?
      ios_platform = JPush::Platform.new
      ios_platform.ios = true
      return ios_platform
      #   else
      #     return JPush::Platform.all
      #   end
      # else
      #   return JPush::Platform.all
      # end
    end

    def pushout
      # if self.receiver
      #   platform = self.receiver.app_platform
      # else
      #   platform = "all"
      # end
      unless Rails.env.test?
        begin
          # push_result = send_payload(message_payload)
          #JPushClient.sendPush message_payload
          # if self.receiver and (ios_platform? || no_platform?)
          # if self.apns and self.receiver
          if self.reveice.status == 1
            send_payload notification_payload(JPush::Platform.new(ios: true))
          end
            # end
            # self.update_columns result: push_result.toJSON, sendout_at: Time.now, broadcast: !self.receiver

        rescue Exception => ex
          Rails.logger.debug ex.inspect
          # PushException.create!(exception: ex.inspect, push: self, platform: platform)
        end
      else
        puts "do not send in test!"
      end
    end
  end
end
