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
        format.json { render json: { status: "unauthorized", message: "ログインが必要です" }, status: :unauthorized }
      end
    end
  end

  protected

  def configure_permitted_parameters
    # resource_class (AdminUser か User か) に応じて許可するキーを分ける
    if resource_class == AdminUser
      # 管理者のログインには email と password を許可
      devise_parameter_sanitizer.permit(:sign_in, keys: [ :email, :password ])
    else
      # 一般ユーザーのログインには account_name を使用（以前の設定に合わせる）
      devise_parameter_sanitizer.permit(:sign_in, keys: [ :account_name, :password ])

      # サインアップと更新の許可設定
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :account_name, :email, :password, :password_confirmation ])
      devise_parameter_sanitizer.permit(:account_update, keys: [ :account_name, :email, :password, :password_confirmation ])
    end
  end

  # ログイン後にどこに飛ばすかを決めるメソッド
  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_root_path # 管理者の場合は /admin へ
    else
      root_path      # 一般ユーザーの場合はトップページへ
    end
  end

  # ログアウト後にどこに飛ばすかを決めるメソッド（任意）
  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :admin_user
      new_admin_user_session_path # 管理者は管理用ログイン画面へ
    else
      root_path                   # 一般ユーザーはトップページへ
    end
  end
end
