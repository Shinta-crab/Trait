class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

   # Deviseのコントローラーが動く時だけ、以下のメソッドを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # 新規登録時に account_name を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:account_name, :email, :password, :password_confirmation])
    # アカウント編集時にも許可したい場合
    devise_parameter_sanitizer.permit(:account_update, keys: [:account_name, :email, :password, :password_confirmation])
  end
end
