class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :sell_items, class_name: :items, foreign_key: :create_user_id
  has_many :buy_items, class_name: :items, foreign_key: :buy_user_id

  before_create :give_initial_point
  before_validation :set_provider
  before_validation :set_uid

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX }, allow_blank: true
  validates :email, uniqueness: true
  validates_confirmation_of :password

  # 初期付与ポイント
  INITIAL_POINT = 1000

  private
  # 新規作成時のポイント付与
  def give_initial_point
    self.point = INITIAL_POINT
  end

  def set_provider
    self.provider = "email" if self.provider.blank?
  end

  def set_uid
    self.uid = self.email if self.uid.blank? && self.email.present?
  end
end
