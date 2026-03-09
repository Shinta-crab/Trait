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

  # 5件制限のバリデーションを追加
  validate :validate_my_styles_limit

  private

  def validate_my_styles_limit
    # 新規作成（保存）時に、既に5件以上ある場合はエラーを追加する
    if my_styles.count >= 5 && !my_styles.exists?(id: id)
      errors.add(:my_styles, "は最大5件までしか保存できません。")
    end
  end
end
