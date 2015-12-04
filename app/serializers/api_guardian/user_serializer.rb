module ApiGuardian
  class UserSerializer < ActiveModel::Serializer
    type 'users'

    attributes :id, :first_name, :last_name, :email, :email_confirmed_at,
               :phone_number, :phone_number_confirmed_at, :created_at, :updated_at

    belongs_to :role
  end
end
