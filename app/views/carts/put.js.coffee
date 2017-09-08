$(".header").replaceWith '<%= render partial: "layouts/header" %>'

$(".cart").replaceWith '<%= render partial: "carts/cart" %>'

<% if xhr_from_carts_controller? %>
$(".delivery-method").replaceWith '<%= render partial: "carts/delivery_method" %>'
$(".apply-coupon").replaceWith '<%= escape_javascript render partial: "carts/apply_coupon" %>'
$(".order-preview").replaceWith '<%= render partial: "carts/order_preview" %>'
<% end %>

window.toggleCartMenu(0)
window.searchBarInit()
window.mobileHeaderInit()


dataLayer.push({
  'event': 'addToCart',
  'ecommerce': {
    'currencyCode': 'TWD',
    'add': {
      'products': [{
        'name': '<%= "#{@item.gamaitem.id}-#{@item.gamaitem.name}" %>',
        'id': '<%= @item.gamaitem.id %>',
        'quantity': <%= @quantity %>,
        'price': <%= @item.gamaitem.price %>
      }]
    }
  }
})

fbq("track", "AddToCart", {
  content_type: 'product',
  content_ids: [<%= @item.gamaitem.id %>],
  value: <%= @item.gamaitem.price %>,
  currency: 'TWD'
})
