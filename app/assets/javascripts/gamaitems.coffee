initBannerSlider = () ->
  $('#owl-slider').owlCarousel(
    singleItem: true
    lazyLoad: true
    theme: 'image-slider-theme'
    autoPlay: 5000
  )

handleImageSlideClick = () ->
  side = $(this).data('side')
  if side is 'prev'
    $('#owl-slider').trigger('owl.prev')
  else
    $('#owl-slider').trigger('owl.next')

toggleClassificationMenu = () ->
  $('#classification-menu').slideToggle(400)

toggleCountryMenu = () ->
  $('#country-menu').slideToggle(400)

toggleSortMenu = () ->
  $('#sort-menu').slideToggle(400)

$(document).on 'ready page:load', (event) ->
  if window.location.pathname.match(/gamaitems\/[0-9]\d*/g) != null
    $(document).scroll ->
      $addToCartBtn = $('.add-to-cart-button.fixed')
      $footer = $('footer').position().top
      $addToCartBtn.css 'position', 'fixed'
      if parseInt($addToCartBtn.offset().top) >= parseInt($('footer').position().top) - 100
        $addToCartBtn.css 'position', 'relative'
      if parseInt($addToCartBtn.offset().top) <= parseInt($(document).scrollTop()) - 100
        $addToCartBtn.css 'position', 'fixed'
  else
    initBannerSlider()
    $('.slider-btn').bind 'click', handleImageSlideClick
    $('#classification-button').bind 'click', toggleClassificationMenu
    $('#country-button').bind 'click', toggleCountryMenu
    $('#sort-button').bind 'click', toggleSortMenu