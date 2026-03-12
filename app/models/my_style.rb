class MyStyle < ApplicationRecord
  belongs_to :user
  belongs_to :genre
  belongs_to :analysis_result

  # 1. 関連するすべての選択データ（Likeした画像すべてとの紐付け）
  has_many :my_style_selections, dependent: :destroy
  has_many :photos, through: :my_style_selections

  # 2. サークルで選ばれた画像（is_selected: true）だけを抽出する関連付け
  # これを定義しておくことで、ビューで @my_style.selected_photos と呼ぶだけで選抜組を取り出せる
  has_many :selected_selections, -> { where(is_selected: true) }, class_name: "MyStyleSelection"
  has_many :selected_photos, through: :selected_selections, source: :photo

  before_create :generate_public_token

  private

  def generate_public_token
    # 重複を避けるためのループ処理（確実性を高める）
    loop do
      self.public_token = "TR-#{SecureRandom.hex(4).upcase.scan(/.{4}/).join('-')}"
      break unless MyStyle.exists?(public_token: self.public_token)
    end
  end
end
