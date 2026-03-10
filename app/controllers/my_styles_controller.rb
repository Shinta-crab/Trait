class MyStylesController < ApplicationController
  before_action :authenticate_user!, except: [:new]

  # 1. プレビュー表示画面（診断直後）
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

  # 2. 保存処理 (上限5件チェック付き)
  def create
    unless user_signed_in?
      return render json: { status: 'unauthorized', message: '保存にはログインが必要です。' }, status: :unauthorized
    end

    # 5件上限のチェック
    if current_user.my_styles.count >= 5
      return render json: { status: 'error', message: '保存できるスタイルは最大5件までです。不要なスタイルを削除してから保存してください。' }, status: :unprocessable_entity
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
          # selections に座標（pos_x, pos_y）を保存
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

  # 3. 保存済みスタイルの詳細表示 (再分析用のデータ取得)
  def show
    @my_style = current_user.my_styles.includes(my_style_selections: :photo).find(params[:id])
    
    @genre = @my_style.genre
    @selections = @my_style.my_style_selections
    @selected_photos = @my_style.selected_photos # has_many through (is_selected: true)

    # 再分析マップ再現用のデータ
    # 最初の selection から当時の中心座標を取得
    first_selection = @selections.first
    @cx = first_selection&.pos_x
    @cy = first_selection&.pos_y
    # 全てのLike済み写真のID（再分析で使用）
    @all_photo_ids = @selections.map(&:photo_id).join(',')
  end

  # 4. スタイル名の更新 (追加)
  def update
    @my_style = current_user.my_styles.find(params[:id])
    if @my_style.update(my_style_params)
      render json: { status: 'success', custom_name: @my_style.custom_name }
    else
      render json: { status: 'error', message: @my_style.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # 5. 削除処理
  def destroy
    @my_style = current_user.my_styles.find(params[:id])
    @my_style.destroy
    redirect_to user_root_path, notice: "スタイルを削除しました。", status: :see_other
  end

  # 6. 一覧表示
  def index
    @my_styles = current_user.my_styles.includes(:genre).order(created_at: :desc)
  end

  private

  def my_style_params
    params.require(:my_style).permit(:custom_name)
  end
end
