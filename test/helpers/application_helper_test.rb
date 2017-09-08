require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "image size helper" do
    rt = extra_size('https://d2gfbj96l0a5kh.cloudfront.net/uploads/asset/gamaitem/1128/main/preload_764922a3-938b-4fb6-9dc4-9745ba2d4413.jpg')
    assert_equal 'https://d2gfbj96l0a5kh.cloudfront.net/uploads/asset/gamaitem/1128/main/extra_764922a3-938b-4fb6-9dc4-9745ba2d4413.jpg', rt
  end
end

