require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup { Visit.delete_all }

  test "root renders hello world" do
    get root_url
    assert_response :success
    assert_select "h1", "Hello, World!"
  end

  test "each request creates a visit record" do
    assert_difference "Visit.count", 3 do
      3.times { get root_url }
    end
  end

  test "total visit count displayed on page matches db" do
    2.times { get root_url }
    get root_url
    assert_select "p", /Total visits:.*3/
  end

  test "recent visits table shows request ip" do
    get root_url
    visit = Visit.last
    assert_select "td", visit.ip_address
  end
end
