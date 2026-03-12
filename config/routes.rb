Rails.application.routes.draw do
  get "pages/terms"
  get "genres/index"
  get "top/index"
  get "/dashboard", to: "dashboards#show", as: :user_root

  # Defines the root path route ("/")
  root "top#index"

  # 1. ユーザー認証関連 (Devise)
  devise_for :users

  # 2. ジャンル選択ページ
  # 「/genres」にアクセスした時にジャンル一覧が出るようにします
  resources :genres, only: [ :index ] do
    member do
      get :main
    end
  end

  # 3. 写真描画のためのルーティング
  resources :likes, only: [ :create ] do
    collection do
      delete :destroy_by_photo # 写真IDを指定して削除するためのカスタムルート
    end
  end

  # 4. 解析結果保存のためのルーティング
  resources :analysis_results, only: [ :create ]

  # 5. マイスタイル表示のためルーティング
  resources :my_styles, only: [ :new, :create, :show, :index, :destroy, :update ]

  # 利用規約へのルート
  get "/terms", to: "pages#terms", as: :terms

  # 以下、Rails標準の設定
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
