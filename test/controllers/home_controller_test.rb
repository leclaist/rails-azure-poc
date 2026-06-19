require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root renders hello world" do
    get root_url
    assert_response :success
    assert_select "h1", "Hello, World!"
  end
end
