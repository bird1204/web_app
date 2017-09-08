openConvenienceStorePopup = () ->
  $.magnificPopup.open({
    items: {
      src: $('#mfp-popup')
    },
    type: 'inline'
    mainClass: 'mfp-fade mfp-popup'
    alignTop: true
    modal: false
  }, 0)

  initMapView()


initMapView = () ->
  if window.google and window.google.maps

    targetLatLng =
      lat: 23.973875
      lng: 120.982024

    window.maps = new window.google.maps.Map(document.getElementById('map-view'), {
      center: targetLatLng
      zoom: 7
      mapTypeControl: false
      streetViewControl: false
      scrollwheel: false
    })

  else
    setTimeout(initMapView, 50)

updateMapCenter = () ->
  unless window.storeInfo.st_name?
    return false

  store = window.storeInfo
  targetLatLng =
    lat: parseFloat(store.longitude)
    lng: parseFloat(store.latitude)

  if window.marker?
    # remove marker
    window.marker.setMap(null)

  window.marker = new window.google.maps.Marker
    map: window.maps
    position: targetLatLng

  $infoWindow = $('<div>')
  $infoWindow.append( $('<div>').addClass('map-store-title').text(store.st_name)).append( $('<div>').addClass('map-store-address').text(store.st_addr)).append( $('<div>').attr('id', 'select-store-button').addClass('map-select-store-button').text('選擇此門市'))

  if window.infoWindow
    window.infoWindow.close()

  window.infoWindow = new google.maps.InfoWindow
    content: $infoWindow.html()
    maxWidth: 320

  center = new google.maps.LatLng(targetLatLng.lat, targetLatLng.lng)

  window.maps.panTo(center)
  window.maps.setZoom(18)
  window.infoWindow.open(window.maps, window.marker)

getStoreCityList = () ->
  $.ajax
    type: 'GET'
    url: '/convenience_stores/city_info'
    success: (data) =>
      $citySelect = $('#store-city-select')
      $(data).each (index, city) ->
        $citySelect.append($("<option>").attr('value', city.id).text(city.name))

getStoreDistrictList = () ->
  $districtSelect = $('#store-district-select')
  $citySelect = $('#store-city-select')

  $.ajax
    type: 'GET'
    url: '/convenience_stores/district_info'
    data:
      city_id: $citySelect.val()
    success: (data) =>
      $districtSelect.find('option').remove()
      $districtSelect.append($("<option>").text('請選擇區域'))
      $(data).each (index, district) ->
        $districtSelect.append($("<option>").attr('value', district.id).text(district.name))

getRoadList = () ->
  $roadSelect = $('#store-road-select')
  $districtSelect = $('#store-district-select')

  $.ajax
    type: 'GET'
    url: '/convenience_stores/road_info'
    data:
      district_id: $districtSelect.val()
    success: (data) =>
      $roadSelect.find('option').remove()
      $roadSelect.append($("<option>").text('請選擇街道'))
      $(data).each (index, road) ->
        $roadSelect.append($("<option>").attr('value', road.id).text(road.name))

getStoreList = () ->
  $.ajax
    type: 'GET'
    url: '/convenience_stores/'
    data:
      road_id: $('#store-road-select').val()
    success: (data) =>
      $storeList = $('#store-list')
      $storeList.html('')
      $(data).each (index, store) ->
        $storeList.append $('<input>').attr('id', 'store-' + store.id).attr('type', 'radio').attr('name', 'conveniencestore').attr('data-store', JSON.stringify(store))

        $storeList.append $('<label>').attr('for', 'store-' + store.id).text(store.in_store_name)

updateStoreId = () ->
  $('input[name="conveniencedstorename"]').val(window.storeInfo.st_name)
  $('input[name="conveniencestoreid"]').val(window.storeInfo.id)
  $('input[name="address"]').val(window.storeInfo.st_addr)

  $.magnificPopup.instance.close()

$(document).ready ->
  $('.checkout-section').on 'click', '.convenience-store-button', openConvenienceStorePopup

  $('.convenience-store-popup').on 'change', '#store-city-select', getStoreDistrictList

  $('.convenience-store-popup').on 'change', '#store-district-select', getRoadList

  $('.convenience-store-popup').on 'change', '#store-road-select', getStoreList

  $('#store-list').on 'click', 'input[name="conveniencestore"]', (e) ->
    window.storeInfo = $(e.target).data().store
    updateMapCenter()

  $('.convenience-store-popup').on 'click', '#select-store-button', updateStoreId

  getStoreCityList()
