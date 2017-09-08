require 'test_helper'

class GamaitemTest < ActiveSupport::TestCase
  test "gamaitem pagination" do
    gamaitems, meta = Gamaitem.page
    assert gamaitems.size > 0
    assert meta.present?
  end

  test "get single gamaitem" do
    gamaitem = Gamaitem.find_by_id(172)
    assert_equal gamaitem.id, "172"
  end
end

