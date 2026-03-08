class MyStylesController < ApplicationController
  before_action :authenticate_user!, except: [:new]

  # 1. プレビュー表示画面（サークル内画像のみ表示）
  def new
    if params[:photo_ids].present?
      @genre = Genre.find(params[:genre_id])
      @selected_photos = Photo.where(id: params[:photo_ids].split(','))
      
      # 振り返り・保存用に全データも保持（Viewのdata属性へ渡す用）
      @all_photo_ids = params[:all_photo_ids]
      @cx = params[:cx]
      @cy = params[:cy]
      @x_axis = params[:x_axis]
      @y_axis = params[:y_axis]
    else
      redirect_to root_path, alert: "診断データが見つかりませんでした。"
    end
  end

  # 2. 保存処理
  def create
    unless user_signed_in?
      return render json: { status: 'unauthorized', message: '保存にはログインが必要です。' }, status: :unauthorized
    end

    ActiveRecord::Base.transaction do
      # 💡 診断時の設定を AnalysisResult に集約して保存
      analysis = AnalysisResult.create!(
        user: current_user,
        analyzed_at: Time.current
      )

      @my_style = MyStyle.create!(
        user: current_user,
        genre_id: params[:genre_id],
        analysis_result: analysis,
        custom_name: params[:custom_name].presence || "#{Genre.find(params[:genre_id]).name}のスタイル"
      )

      # 「Likeした全画像」を保存
      if params[:all_photo_ids].present?
        # photo_id は DB上 bigint(Integer) なので、判定用に数値配列化しておくと確実です
        all_ids = params[:all_photo_ids].split(',')
        selected_ids = params[:photo_ids].to_s.split(',').map(&:to_i)

        all_ids.each do |p_id|
          MyStyleSelection.create!(
            my_style: @my_style,
            photo_id: p_id,
            # 💡 そのIDがサークル内(selected_ids)に含まれていれば true
            is_selected: selected_ids.include?(p_id.to_i),
            pos_x: params[:cx], 
            pos_y: params[:cy]
          )
        end
      end
    end

    render json: { status: 'success', redirect_url: '/dashboard' }
  rescue => e
    # ログを出力して原因を特定しやすくする
    logger.error "MyStyle Save Error: #{e.message}"
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end

  # 過去に保存したスタイルの一覧表示
  def index
    # ログインユーザーに紐づくスタイルを新しい順に取得
    @my_styles = current_user.my_styles.includes(:genre).order(created_at: :desc)
  end

  # 保存済みスタイルの詳細表示
  def show
    # 他人のスタイルを見られないよう current_user を起点に検索
    # includes を使って写真データの一括取得（N+1問題対策）を行う
    @my_style = current_user.my_styles.includes(my_style_selections: :photo).find(params[:id])
    
    # ビューの互換性を保つための変数定義
    @genre = @my_style.genre
    @selections = @my_style.my_style_selections
    @selected_photos = @my_style.selected_photos
  end
end
