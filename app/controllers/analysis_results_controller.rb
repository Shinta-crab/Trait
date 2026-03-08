class AnalysisResultsController < ApplicationController
  def create
    # ※ current_user が存在しない場合は User.first 等でテスト
    target_user = current_user || User.first 

    ActiveRecord::Base.transaction do
      # 1. 分析親レコード
      analysis = AnalysisResult.create!(user: target_user, analyzed_at: Time.current)

      # 2. マイスタイル（Solo/Duo/Trioの判定ロジックは今後追加可能）
      @my_style = MyStyle.create!(
        user: target_user,
        genre_id: params[:genre_id],
        analysis_result: analysis,
        custom_name: "#{Genre.find(params[:genre_id]).name}のスタイル"
      )

      # 3. 5〜12枚の選択された写真を保存
      params[:selections].each do |sel|
        MyStyleSelection.create!(
          my_style: @my_style,
          photo_id: sel[:photo_id],
          pos_x: sel[:pos_x],
          pos_y: sel[:pos_y]
        )
      end
    end

    # 成功レスポンスと、次に移動すべきURLを返す
    render json: { status: 'success', redirect_url: my_style_path(@my_style) }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
