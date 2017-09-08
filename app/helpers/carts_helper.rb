module CartsHelper

  # TODO move to carts helper
  def step_n_datalayer(n, cart=nil)

    data = {
      event: 'checkout',
      ecommerce: {
        checkout: {
          actionField: {step: n},
        }
      }
    }


    if cart.present?
      products = cart.line_items.map do |line_item|
        {
          name: line_item.gamaitem.name,
          id: line_item.gamaitem.id,
          quantity: line_item.quantity
        }
      end
      data[:ecommerce][:checkout][:products] = products
      data
    else
      data
    end

  end

  def xhr_from_carts_controller?
    begin
      parsed = Rails.application.routes.recognize_path(request.referrer)
      parsed[:controller] == 'carts'
    rescue
      false
    end
  end

end
