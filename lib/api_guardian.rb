require 'rails-api'
require 'active_job'
require 'pundit'
require 'paranoia'
require 'rack/cors'
require 'kaminari'
require 'zxcvbn'
require 'phony'
require 'twilio-ruby'
require 'active_model_otp'
require 'active_model_serializers'
require 'api_guardian/configuration'
require 'api_guardian/engine'

require 'active_support/lazy_load_hooks'

module ApiGuardian
  ActiveSupport.run_load_hooks(:api_guardian_configuration, Configuration)

  module Concerns
    module ApiErrors
      autoload :Handler, 'api_guardian/concerns/api_errors/handler'
      autoload :Renderer, 'api_guardian/concerns/api_errors/renderer'
    end

    module ApiRequest
      autoload :Validator, 'api_guardian/concerns/api_request/validator'
    end
  end

  module Errors
    autoload :InvalidContentTypeError, 'api_guardian/errors/invalid_content_type_error'
    autoload :InvalidPermissionNameError, 'api_guardian/errors/invalid_permission_name_error'
    autoload :InvalidRequestBodyError, 'api_guardian/errors/invalid_request_body_error'
    autoload :InvalidRequestResourceIdError, 'api_guardian/errors/invalid_request_resource_id_error'
    autoload :InvalidRequestResourceTypeError, 'api_guardian/errors/invalid_request_resource_type_error'
    autoload :InvalidUpdateActionError, 'api_guardian/errors/invalid_update_action_error'
    autoload :ResetTokenExpiredError, 'api_guardian/errors/reset_token_expired_error'
    autoload :ResetTokenUserMismatchError, 'api_guardian/errors/reset_token_user_mismatch_error'
    autoload :PhoneNumberInvalid, 'api_guardian/errors/phone_number_invalid'
    autoload :PasswordRequired, 'api_guardian/errors/password_required'
    autoload :PasswordInvalid, 'api_guardian/errors/password_invalid'
    autoload :TwoFactorRequired, 'api_guardian/errors/two_factor_required'
  end

  module Stores
    autoload :Base, 'api_guardian/stores/base'
    autoload :UserStore, 'api_guardian/stores/user_store'
    autoload :RoleStore, 'api_guardian/stores/role_store'
    autoload :PermissionStore, 'api_guardian/stores/permission_store'
  end

  module Policies
    autoload :ApplicationPolicy, 'api_guardian/policies/application_policy'
    autoload :PermissionPolicy, 'api_guardian/policies/permission_policy'
    autoload :RolePolicy, 'api_guardian/policies/role_policy'
    autoload :UserPolicy, 'api_guardian/policies/user_policy'
  end

  module Validators
    autoload :PasswordLengthValidator, 'api_guardian/validators/password_length_validator'
    autoload :PasswordScoreValidator, 'api_guardian/validators/password_score_validator'
  end

  module Strategies
    autoload :PasswordAuthentication, 'api_guardian/strategies/password_authentication'
    autoload :TwoFactorAuthentication, 'api_guardian/strategies/two_factor_authentication'
  end

  module Jobs
    autoload :SendOtp, 'api_guardian/jobs/send_otp'
    autoload :SendSms, 'api_guardian/jobs/send_sms'
  end

  class << self
    attr_accessor :current_request
    attr_writer :configuration

    def zxcvbn_tester
      @zxcvbn_tester ||= ::Zxcvbn::Tester.new
    end

    def twilio_client
      unless configuration.enable_2fa
        fail Configuration::ConfigurationError.new('2FA is not enabled!')
      end
      @twilio_client ||= ::Twilio::REST::Client.new configuration.twilio_id, configuration.twilio_token
    end
  end

  module_function
  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
  end
end
