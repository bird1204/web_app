module ApplicationHelper

  SIZE_NAMES = [:extra, :large, :normal, :small, :thumb, :mini, :preload, :web_topic]

  SIZE_NAMES.each do |name|
    define_method "#{name}_size" do |url|
      # https://d2gfbj96l0a5kh.cloudfront.net/uploads/asset/gamaitem/1128/main/preload_764922a3-938b-4fb6-9dc4-9745ba2d4413.jpg
      url.sub(/#{SIZE_NAMES.map{|n| "(#{n})"}.join('|')}/, name.to_s)
    end
  end

  def toggle_classifications classifications
    return false unless classifications.map(&:id).include?(params[:id].to_i)
    paths = request.original_fullpath.match(/\/classifications\/([0-9]*)/)
    return false unless paths.present?
    return false unless paths[1].include?(params[:id])
    true
  end

  def image url, name, sizes, class_name=nil, alt_text=nil, options={}
    alt_text ||= "#{name}｜甘仔店｜柑仔店"
    if rand(1) == 1
      alt_text = alt_text.gsub('柑仔店', '甘仔店')
    end
    if options[:itemprop].present?
      image_tag "#{eval("#{sizes[0]}_size('#{url}')")}", class: class_name, srcset: "#{eval("#{sizes[1]}_size('#{url}')")} 2x", alt: alt_text, title: alt_text, itemprop: options[:itemprop]
    else
      image_tag "#{eval("#{sizes[0]}_size('#{url}')")}", class: class_name, srcset: "#{eval("#{sizes[1]}_size('#{url}')")} 2x", alt: alt_text, title: alt_text
    end
  end

end
