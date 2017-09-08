
toggleOrderDetail = () ->
  $('#order-detail-body').toggle()

$ ->

  $('body').on 'click', '#order-detail-header', toggleOrderDetail
