$(".header").replaceWith '<%= render partial: "layouts/header" %>'
$(".cart").replaceWith '<%= render partial: "carts/cart" %>'

window.mobileHeaderInit()

$('#search-btn').on 'click', () ->
  $('.open-full-screen').css('display', 'block')
