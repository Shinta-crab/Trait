class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  # 未ログイン時のDeviseの挙動をオーバーライド
  def authenticate_user!
    if user_signed_in?
      super
    else
      respond_to do |format|
        # 通常のブラウザアクセス（HTML）はこれまで通りログイン画面へ
        format.html { super }
        # APIアクセス（JSON）はリダイレクトせず401を返す
        format.json { render json: { status: 'unauthorized', message: 'ログインが必要です' }, status: :unauthorized }
      end
    end
  end

  protected

  def configure_permitted_parameters
    # account_name だけでなく、email と password も明示的に許可リストに載せる
    devise_parameter_sanitizer.permit(:sign_up, keys: [:account_name, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:account_name, :email, :password, :password_confirmation])
  end

  # ログイン（新規登録後の自動ログイン含む）の遷移先を指定
  def after_sign_in_path_for(resource)
    user_root_path # /dashboard へ
  end
end
