class Genre < ApplicationRecord
  # 1つのジャンルには、たくさんの写真が紐付く
  has_many :photos, dependent: :destroy

  # バリデーション：名前とスラグは必須
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
end
