class LikesController < ApplicationController
  before_action :authenticate_user!

  # POST /likes (Likeしたとき)
  def create
    @like = current_user.likes.find_or_initialize_by(photo_id: params[:photo_id])
    @like.touch if @like.persisted?
    if @like.save
      render json: { status: "liked" }
    else
      # 失敗時の処理がないと、保存に失敗したときにrenderが呼ばれずエラーになる可能性があります
      render json: { status: "error", errors: @like.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /likes (Dislikeしたとき)
  # スワイプ画面から photo_id を送って、既存のLikeがあれば消す
  def destroy_by_photo
    @like = current_user.likes.find_by(photo_id: params[:photo_id])
    @like.destroy if @like
    render json: { status: "unliked" }
  end
end
