require 'test_helper'

class LineTest < ActiveSupport::TestCase

  test "load gamaitem" do

    line_item = LineItem.new gamaitem_id: 172, quantity: 1

    assert_equal line_item.gamaitem.id, "172"
  end

  test "set gamaitem" do
    line_item = LineItem.new gamaitem: Gamaitem.new(id: 172), quantity: 1
    assert line_item.gamaitem.name.present?
  end

end


