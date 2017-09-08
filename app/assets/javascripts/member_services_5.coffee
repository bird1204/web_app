window.updateAmount = (isReturnAll) ->
  @order = JSON.parse(window.order_json)
  refund = 0
  discount = 0
  total_amount_refund = 0
  gamaitemIds = @order.gamaitems.map (gamaitem) ->
    gamaitem.gamaid

  if isReturnAll
    $.each @order.gamaitems, (index, gamaitem) ->
      $(document.getElementById("member_service_comment_head_[#{gamaitemIds.indexOf(gamaitem.gamaid)}][quantity]")).val gamaitem.gamaitcount
      refund += parseInt(gamaitem.gamaitcount) * parseInt(gamaitem.price) 
  else
    $.each @order.gamaitems, (index, gamaitem) ->
      refund += parseInt($(document.getElementById("member_service_comment_head_[#{gamaitemIds.indexOf(gamaitem.gamaid)}][quantity]")).val()) * parseInt(gamaitem.price) 

  $('#member_service_total_refund').val refund

  discount = parseInt(@order.totalprice) - parseInt(@order.subtotal) - parseInt(@order.shipping)
  total_amount_refund = parseInt(refund) + parseInt(@order.shipping) + parseInt(discount)

  #全退，退運費
  if parseInt(total_amount_refund) == parseInt(@order.totalprice)
    $('#member_service_shipping_refund').val parseInt(@order.shipping)
    $('#member_service_total_amount_refund').val total_amount_refund
    $('#member_service_discount').val discount
  else
    $('#member_service_shipping_refund').val 0
    $('#member_service_discount').val 0
    $('#member_service_total_amount_refund').val parseInt(refund)


$(document).on 'ready page:load change', ->
  window.initTwZipCode()


