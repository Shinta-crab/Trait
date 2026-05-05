class Genre < ApplicationRecord
  # 1つのジャンルには、たくさんの写真が紐付く
  has_many :photos, dependent: :destroy

  #  enumの定義（関連付けの直後に置くのが一般的）
  enum :status, { open: 0, maintenance: 1, hidden: 2 }

  # バリデーション：名前とスラグは必須
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
end
