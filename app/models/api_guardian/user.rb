module ApiGuardian
  class User < ActiveRecord::Base
    acts_as_paranoid
    has_secure_password
    has_one_time_password

    belongs_to :role, class_name: ApiGuardian.configuration.role_class.to_s

    delegate :can?, :cannot?, to: :role

    validates :email, presence: true, uniqueness: true
    validates :phone_number, uniqueness: true, case_sensitive: false
    validates_with ApiGuardian::Validators::PasswordLengthValidator, if: :password
    validates_with ApiGuardian::Validators::PasswordScoreValidator, if: :password

    # Class Methods
    def self.policy_class
      ApiGuardian::Policies::UserPolicy
    end

    # Instance Methods
    def reset_password_token_valid?
      !reset_password_sent_at.nil? && 24.hours.ago <= reset_password_sent_at
    end
  end
end
