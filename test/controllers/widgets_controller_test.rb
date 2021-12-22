require "test_helper"

class WidgetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get widgets_index_url
    assert_response :success
  end

  test "should get import" do
    get widgets_import_url
    assert_response :success
  end
end
