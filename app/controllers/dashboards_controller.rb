class DashboardsController < ApplicationController
  before_action :authenticate_user! # ログイン必須

  def show
    # ログインユーザーが保存したスタイルをすべて取得
    # @my_styles = current_user.my_styles.includes(:genre).order(created_at: :desc)
  end
end
