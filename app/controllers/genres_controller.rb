class GenresController < ApplicationController
  def index
    # 全てのジャンルを取得して、ビューに渡す
    @genres = Genre.all
  end

  # 診断（スワイプ）画面用のアクション
  def main
    @genre = Genre.find(params[:id])
    # そのジャンルに紐づく写真をランダムに10枚選ぶ（一例）
    @photos = @genre.photos.order("RANDOM()").limit(50)
    # 写真が100枚あったらその中から50枚を選ぶは場合はlimit 50にすればOK
  end
end
