require 'test_helper'

class CartTest < ActiveSupport::TestCase
  test "put" do
    cart = Cart.new
    cart.put(Gamaitem.new(id: 172, sku: 999))
    cart.put(Gamaitem.new(id: 172, sku: 999))

    assert_equal 1, cart.line_items.size
    assert_equal 172, cart.line_items.first.gamaitem_id
    assert_equal 2, cart.line_items.first.quantity
  end

  test "take" do
    cart = Cart.new
    cart.put(Gamaitem.new(id: 172, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))

    cart.take(Gamaitem.new(id: 172, sku: 999))

    assert_equal 1, cart.line_items.size
    assert_equal 173, cart.line_items.first.gamaitem_id
    assert_equal 2, cart.line_items.first.quantity
  end

  test "serialize" do
    cart = Cart.new
    cart.put(Gamaitem.new(id: 172, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))
    cart.take(Gamaitem.new(id: 173, sku: 999))

    assert_equal({"raw_line_items"=>{"172"=>1, "173"=>1}}, cart.as_json.slice("raw_line_items"))
    assert_equal 172, cart.from_json(cart.to_json).line_items.first.gamaitem_id
  end

  test "satisfy item limitation" do
    cart = Cart.new
    cart.put(Gamaitem.new(id: 172, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))

    assert cart.satisfy_item_limitation("1-172,1-173", 1)
    assert !cart.satisfy_item_limitation("5-172,10-173", 1)
    assert cart.satisfy_item_limitation("1-172,10-173", 2)
  end

  test "maximum quantity" do
    cart = Cart.new

    cart.put(Gamaitem.new(id: 172, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))

    assert_equal({"raw_line_items"=>{"172"=>1, "173"=>1}}, cart.as_json.slice("raw_line_items"))

    cart.put(Gamaitem.new(id: 173, sku: 999), 100)

    assert_equal({"raw_line_items"=>{"172"=>1, "173"=>1}}, cart.as_json.slice("raw_line_items"))
  end

  test "check sku" do
    cart = Cart.new
    cart.put(Gamaitem.new(id: 173, sku: 10), 15)
    assert_equal({"raw_line_items"=>{"173"=>10}}, cart.as_json.slice("raw_line_items"))

    cart.put(Gamaitem.new(id: 173, sku: 10), 9)
    assert_equal({"raw_line_items"=>{"173"=>19}}, cart.as_json.slice("raw_line_items"))
  end

  test "take all of an item" do
    cart = Cart.new
    cart.put(Gamaitem.new(id: 172, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))
    cart.put(Gamaitem.new(id: 173, sku: 999))

    cart.take_all_of_a(Gamaitem.new(id: 173))
    assert_equal({"raw_line_items"=>{"172"=>1, "173"=>0}}, cart.as_json.slice("raw_line_items"))

    cart.take_all_of_a(Gamaitem.new(id: 172))
    assert_equal({"raw_line_items"=>{"172"=>0, "173"=>0}}, cart.as_json.slice("raw_line_items"))
  end

  # test "availability of convenience store" do
  #   cart = Cart.new
  #   cart.put(Gamaitem.new(id: 172))
  #   cart.put(Gamaitem.new(id: 173))

  #   assert_equal true, cart.convenience_store_available?
  # end

  # weight? && end_edge? && all_edge? && volume?
  test "weight?" do
    cart = Cart.new
    cart.stub :conditions, cart.conditions.merge({cvs_maximum_weight: 0.01}) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999})
      assert_equal false, cart.send(:weight?)
    end

    cart.stub :conditions, cart.conditions.merge({cvs_maximum_weight: 9.99}) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999})
      assert_equal true, cart.send(:weight?)
    end
  end

  test "end_edge?" do
    cart = Cart.new
    cart.stub :conditions, cart.conditions.merge({cvs_maximum_total_eedge: 30}) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999})
      assert_equal true, cart.send(:end_edge?)
    end

    cart.stub :conditions, cart.conditions.merge({cvs_maximum_total_eedge: 30}) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999}, 20)
      assert_equal false, cart.send(:end_edge?)
    end
  end

  test "all_edge?" do
    cart = Cart.new
    cart.stub :conditions, cart.conditions.merge({
      cvs_maximum_ledge: 47,
      cvs_maximum_sedge: 32,
      cvs_maximum_eedge: 30,
    }) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999}, 20)
      assert_equal true, cart.send(:all_edge?)
    end

    cart.stub :conditions, cart.conditions.merge({
      cvs_maximum_ledge: 47,
      cvs_maximum_sedge: 0.1,
      cvs_maximum_eedge: 30,
    }) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999}, 20)
      assert_equal false, cart.send(:all_edge?)
    end
  end

  test "volume?" do
    cart = Cart.new

    cart.stub :conditions, cart.conditions.merge({
      cvs_maximum_volume_V2: 37000
    }) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999})
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999})
      assert_equal true, cart.send(:volume?)
    end

    cart.stub :conditions, cart.conditions.merge({
      cvs_maximum_volume_V2: 37000
    }) do
      cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999}, 20)
      cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999}, 30)
      cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999}, 30)
      assert_equal false, cart.send(:volume?)
    end
  end

  test "convenience_store_available?" do
    cart = Cart.new

    cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999})
    cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999})
    cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999})
    assert_equal true, cart.convenience_store_available?

    cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999}, 50)
    cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999}, 50)
    cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999}, 50)
    assert_equal false, cart.convenience_store_available?
  end

  test "why cannot checkout?" do
    cart = Cart.new

    cart.put(Gamaitem.find_by_id(196).tap {|item| item.sku = 999})
    cart.put(Gamaitem.find_by_id(436).tap {|item| item.sku = 999})
    cart.put(Gamaitem.find_by_id(666).tap {|item| item.sku = 999})

    assert_equal ['韓國人氣魷魚大腳 1包入 庫存不足', '韓國人氣魷魚大腳 1包入 無法購買'],
        cart.why_cannot_checkout?

  end

end
