class Photo < ApplicationRecord
  belongs_to :genre
  # optional: true を追記（これで nil を許容します）
  belongs_to :main_style, optional: true

  has_many :likes, dependent: :destroy
  has_many :photo_scores, dependent: :destroy

  # Photo経由でPhotoScoreを作成・更新・削除できるようにする
  accepts_nested_attributes_for :photo_scores, allow_destroy: true

  has_one_attached :image

  def display_image_url
    # 1. Active Storageに画像が添付されているか確認
    if image.attached?
      # Active StorageのURLを返す
      return Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
    
    # 2. なければ従来の image_path ロジックを実行
    return nil if image_path.blank?

    # 3. 候補となるパスのリストを作成する
    # 例: ["living/image0.jpeg", "living/image0.jpg"]
    paths = [image_path]
    if image_path.include?(".jpeg")
      paths << image_path.gsub(".jpeg", ".jpg")
    elsif image_path.include?(".jpg")
      paths << image_path.gsub(".jpg", ".jpeg")
    end

    paths.each do |path|
      begin
        # アセットが存在するかチェック（存在しなければ例外が発生する）
        return ActionController::Base.helpers.asset_path(path)
      rescue
        # なかったら次のパスを試す
        next
      end
    end

    # 5. 全てダメだった場合
    Rails.logger.error "【画像未検出】: 候補 #{paths.join(', ')} は全て見つかりませんでした。"
    nil
  end
end
