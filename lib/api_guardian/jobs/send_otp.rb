module ApiGuardian
  module Jobs
    class SendOtp < ActiveJob::Base
      queue_as :default

      def perform(user)
        return unless user.otp_enabled?

        unless user.phone_number.present? && user.phone_number_confirmed_at.present?
          Rails.logger.error '[ApiGuardian] User does not have a confirmed phone number! Cannot send OTP.'
          return
        end

        body = "#{user.otp_code} is your authentication code."

        ApiGuardian.twilio_client.messages.create(
          from: ApiGuardian.configuration.twilio_send_from,
          to: user.phone_number,
          body: body
        )
      end
    end
  end
end