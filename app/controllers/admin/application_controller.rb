module Admin
  class ApplicationController < Administrate::ApplicationController
    # ログイン済みの AdminUser かどうかをチェック
    before_action :authenticate_admin

    def authenticate_admin
      # ここに独自の追加権限チェックを入れることも可能
      authenticate_admin_user!
    end

    # 1ページあたりの表示件数を調整したい場合はここ（任意）
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
