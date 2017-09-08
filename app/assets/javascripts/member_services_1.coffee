$(document).on 'ready page:load change', ->
  window.initTwZipCode()
  $('#member_service_comment_invoice_type').on 'change', () ->
    if $(this).val() == '1'
      $('.des-invoice-seven-notitext').show()
      $('.triple-invoice').hide()
      $('#member_service_comment_invoice_buyer_ubn').removeAttr('required')
    else
      $('.des-invoice-seven-notitext').hide()
      $('.triple-invoice').show()
      $('#member_service_comment_invoice_buyer_ubn').attr('required', 'required')

  $('#member_service_comment_invoice_carrier_type').on 'change', () ->
    $member_service_comment_invoice_carrier_num = $('#member_service_comment_invoice_carrier_num')
    switch $(this).val()
      when "1" 
        $member_service_comment_invoice_carrier_num.attr('placeholder', "請輸入手機載具編號")
        $member_service_comment_invoice_carrier_num.show()
      when "2" 
        $member_service_comment_invoice_carrier_num.attr('placeholder', "請輸入自然人載具編號")
        $member_service_comment_invoice_carrier_num.show()
      when "3" 
        $member_service_comment_invoice_carrier_num.attr('placeholder', "")
        $member_service_comment_invoice_carrier_num.hide()
        

