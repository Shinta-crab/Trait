require "test_helper"

class GenresControllerTest < ActionDispatch::IntegrationTest
  # fixtures :all はテスト実行の最初に一度だけ行う
  fixtures :all

  setup do
    # 依存関係を明示的にクリアしてからテストを開始する
    @user = users(:one)
    @genre = genres(:one)
    @photo = photos(:one) # ここで photos が読み込まれることを保証
    @like = likes(:one)
  end
  test "should get index" do
    get genres_index_url
    assert_response :success
  end
end
