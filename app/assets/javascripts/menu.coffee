window.toggleAccountMenu = () ->
  $('.account-dropdown-menu').slideToggle('fast')

window.toggleCartMenu = (toggleAnimation = 'fast') ->
  $('.cart-dropdown-menu').slideToggle(toggleAnimation)

window.mobileHeaderInit = () ->
  if $('html').attr('is-mobile-devise') == 'true'
    $('.nav-toggle').on 'click', ->
      window.toggleMobileNavi() 
    $('#classificationOverlay').on 'click', ->
      $('#classificationOverlay').hide()
      $('#classificationSideBar').hide()
      if $('#filter_sidebar') != null
        $('#filter_sidebar').hide()

window.toggleMobileNavi = () ->
  # $('.nav-toggle').toggleClass 'is-active'
  # $('.nav-menu').toggleClass 'is-active'
  $('#classificationSideBar').toggle()
  if $('#classificationSideBar').is(':visible')
    $('#classificationOverlay').show()
  else
    $('#classificationOverlay').hide()
  if $('#filter_sidebar') != null
    $('#filter_sidebar').hide()

window.refreshCart = () ->
  $.ajax
    url: '/carts'
    data: {}
    success: ->
    dataType: 'script'
    beforeSend: ->
      $('.loader').hide()
      $('.loader-overlap').hide()

window.searchBarInit = () ->
  $('#search-btn').on 'click', () ->
    $('.open-full-screen').css('display', 'block')

window.myAccFunc = (obj, index) ->
  $(obj).siblings('div').each (counter, sibling) ->
    if counter == index
      $(sibling).toggleClass 'w3-show'
    else
      $(sibling).removeClass 'w3-show'
    return
  return

$(window). bind 'pageshow', (event) ->
  window.refreshCart()

$(document).on 'ready page:load change', (event) ->
  window.mobileHeaderInit()
  window.searchBarInit()

  window.mouseInCart = false
  window.mouseInAccount = false

  if document.documentElement.getAttribute('shouldShowBanner') == 'true'
    $('#low-fee-banner').show()
    lastScrollTop = 0
    $(window).scroll (event) ->
      st = $(this).scrollTop()
      
      if st < lastScrollTop || st == 0
        $('#low-fee-banner').show()
      else
        $('#low-fee-banner').hide()
        
      lastScrollTop = st
      return

  $('.header-message').fadeOut 10000

  $('.open-full-screen .head').on 'click', () ->
    $('.open-full-screen').css('display', 'none')
    
  $('#search-btn').on 'click', () ->
    $('.open-full-screen').css('display', 'block')

  $('header').on 'click', '#account-button', window.toggleAccountMenu
  $('header').on 'mouseenter', '#account-button', () ->
    $('.account-dropdown-menu').slideToggle('fast')
    window.mouseInAccount = true

  $('header').on 'mouseleave', '.header, .account-button-wrapper', () ->
    if window.mouseInAccount
      window.mouseInAccount = false
      setTimeout (->
        unless window.mouseInAccount
          $('.account-dropdown-menu').slideUp(300)
      ), 1500

  $('header').on 'click', '#cart-button', window.toggleCartMenu
  $('header').on 'mouseenter', '#cart-button, .cart-dropdown-menu', () ->
    $('.cart-dropdown-menu').slideDown('fast')
    window.mouseInCart = true

  $('header').on 'mouseleave', '.header, .cart-dropdown-menu', () ->
    if window.mouseInCart
      window.mouseInCart = false
      setTimeout (->
        unless window.mouseInCart
          $('.cart-dropdown-menu').slideUp(400)
      ), 1500

  $('body').on 'click', '.page', () ->
    if $('.cart-dropdown-menu').is(':visible')
      $('.cart-dropdown-menu').hide('fast')

  $('header').on 'click', '.cart-close', () ->
    $('.cart-dropdown-menu').slideUp(400)

  $(document).ajaxStart ->
    $('.loader').show()
    $('.loader-overlap').show()

  $(document).ajaxComplete ->
    $('.loader').hide()
    $('.loader-overlap').hide()