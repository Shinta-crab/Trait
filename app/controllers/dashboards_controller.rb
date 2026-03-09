class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @my_styles = current_user.my_styles.includes(:genre).order(created_at: :desc)
    
    # 最大5枠。既に5件以上ある場合は empty_slots_count を 0 にする
    max_slots = 5
    @empty_slots_count = [max_slots - @my_styles.count, 0].max
  end
end

