class MyStylesController < ApplicationController
  before_action :authenticate_user!, except: [:new]

  # 1. プレビュー表示画面
  def new
    if params[:photo_ids].present?
      @genre = Genre.find(params[:genre_id])
      @selected_photos = Photo.where(id: params[:photo_ids].split(','))
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

    # 💡 5件上限のチェック
    if current_user.my_styles.count >= 5
      return render json: { status: 'error', message: '保存できるスタイルは最大5件までです。不要なスタイルを削除してください。' }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
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

      if params[:all_photo_ids].present?
        all_ids = params[:all_photo_ids].split(',')
        selected_ids = params[:photo_ids].to_s.split(',').map(&:to_i)

        all_ids.each do |p_id|
          MyStyleSelection.create!(
            my_style: @my_style,
            photo_id: p_id,
            is_selected: selected_ids.include?(p_id.to_i),
            pos_x: params[:cx], 
            pos_y: params[:cy]
          )
        end
      end
    end

    render json: { status: 'success', redirect_url: '/dashboard' }
  rescue => e
    logger.error "MyStyle Save Error: #{e.message}"
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end

  # 3. 削除処理（追加）
  def destroy
    # current_user経由で検索することで、他人のデータを削除できないようにします
    @my_style = current_user.my_styles.find(params[:id])
    @my_style.destroy
    
    # 削除後はダッシュボードへリダイレクト
    # Rails 7以降のTurbo環境では status: :see_other を付けるのが推奨されます
    redirect_to user_root_path, notice: "スタイルを削除しました。", status: :see_other
  end

  def index
    @my_styles = current_user.my_styles.includes(:genre).order(created_at: :desc)
  end

  def show
    @my_style = current_user.my_styles.includes(my_style_selections: :photo).find(params[:id])
    @genre = @my_style.genre
    @selections = @my_style.my_style_selections
    @selected_photos = @my_style.selected_photos
  end
end
