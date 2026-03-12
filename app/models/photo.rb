class Photo < ApplicationRecord
  belongs_to :genre
  # optional: true を追記（これで nil を許容します）
  belongs_to :main_style, optional: true

  has_many :likes, dependent: :destroy
  has_many :photo_scores, dependent: :destroy

  # MVP仕様: DBのimage_pathをAsset PipelineのURLに変換する
  def display_image_url
    return nil if image_path.blank?

    # DB内の image_path が "living/image0.jpeg" であることを前提に、
    # ActionControllerのヘルパーを使用して、
    # Railsのアセットパスに変換します。
    begin
      ActionController::Base.helpers.asset_path(image_path)
    rescue
      # 見つからない場合、拡張子を入れ替えて再トライしてみる
      alternative_path = image_path.include?(".jpeg") ? image_path.gsub(".jpeg", ".jpg") : image_path.gsub(".jpg", ".jpeg")

      begin
        ActionController::Base.helpers.asset_path(alternative_path)
      rescue
        # 両方ダメなら諦めてログを出す
        Rails.logger.error "【画像未検出】: #{image_path} も #{alternative_path} も見つかりませんでした。"
        nil
      end
    end
  end
end
