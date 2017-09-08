class LineItem < Base

  attr_accessor :gamaitem_id, :gamaitem, :quantity

  def gamaitem
    # load
    Gamaitem.find_by_id(@gamaitem_id)
  end

  def gamaitem=(gamaitem)
    @gamaitem_id = gamaitem.id
  end

end
