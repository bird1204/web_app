# = require lib/jquery.twzipcode.min
# = require convenience_store
# = require order_preview

initTwZipCode = () ->
  $('#twzipcode').twzipcode
    'zipcodeIntoDistrict': true
    'hideCounty': ['金門縣', '連江縣', '澎湖縣']

render = () ->
  invoiceType = $('input[name="invoice_types"]:checked').val()
  $("#invoice-container").toggle(invoiceType == "0")
  $("#donation").toggle(invoiceType == "1")
  $("#invoice-info").toggle(invoiceType == "2")
  carrierType = $('input[name="carrier_type"]:checked').val()
  $("#carrier-type-personal").toggle(carrierType == "1")
  $("#carrier-type-phone").toggle(carrierType == "2")

$(document).ready ->
  initTwZipCode()

  $('input[name="invoice_types"]').change render
  $('input[name="carrier_type"]').change render
  render()

  $('form').on 'change', () ->
    $('input:hidden').removeAttr('required')
    $('input:visible').attr('required', 'required')
    $('select:visible').attr('required', 'required')

  $('form').trigger 'change'
