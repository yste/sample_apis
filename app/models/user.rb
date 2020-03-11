class User < ApplicationRecord
  # Include default devise modules.
  if defined?(Devise)
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
    include DeviseTokenAuth::Concerns::User
  end
end
