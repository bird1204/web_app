module CouponsHelper
  def use_coupon_code cart
    if cart.coupon.present?
      link_to '取消使用', carts_remove_coupon_path, id: 'use-coupon-code', class: 'gama-button', remote: true, method: :post
    else
      link_to '使用', carts_apply_coupon_path, id: 'use-coupon-code', class: 'gama-button', remote: true, method: :post
    end
  end

  def coupon_code_default cart
    !flash.alert.present? ? cart.coupon.try(:code) : params[:promocode]
  end

  def coupon_code_blank coupons
    "#{coupons.present? ? '選擇我的優惠卷' : '沒有優惠卷可以使用'}"
  end

  def coupon_humanlize coupons
    if coupons.kind_of?(Array)
      coupons.map{|coupon|
        case coupon.type
        when "1"
          ["單筆打#{(coupon.discount.to_f * 100.0).to_i.to_s.remove('0')}折", coupon.code]
        when "2"
          ["單筆折抵#{coupon.discount}元", coupon.code]
        end
      }
    else
      coupon = coupons
      case coupon.type
      when "1"
        "單筆打#{(coupon.discount.to_f * 100.0).to_i.to_s.remove('0')}折"
      when "2"
        "單筆折抵#{coupon.discount}元"
      end
    end
  end

end
