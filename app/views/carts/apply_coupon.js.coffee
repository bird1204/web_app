$(".header").replaceWith '<%= render partial: "layouts/header" %>'

$(".cart").replaceWith '<%= render partial: "carts/cart" %>'

$(".apply-coupon").replaceWith '<%= escape_javascript render partial: "carts/apply_coupon" %>'

$(".order-preview").replaceWith '<%= render partial: "carts/order_preview" %>'
