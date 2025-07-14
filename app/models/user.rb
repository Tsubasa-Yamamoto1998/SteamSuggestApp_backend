class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  validates :username, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false, scope: :provider }
  validates :encrypted_password, presence: true
end
