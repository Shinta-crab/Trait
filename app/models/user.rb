class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :likes, dependent: :destroy
  has_many :liked_photos, through: :likes, source: :photo
  has_many :analysis_results, dependent: :destroy
  has_many :my_styles, dependent: :destroy
  
  # アカウント名のバリデーションを追加
  validates :account_name, presence: true, uniqueness: true
end
