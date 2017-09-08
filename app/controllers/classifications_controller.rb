class ClassificationsController < ApplicationController
  def show
    @classification = Classification.find_by_id(params[:id])
    @gamaitems, @meta, @tags_hash, @areas = @classification.filter(
      params[:page] ||= 1,
      params[:sort_id] ||= 1,
      params[:tag_ids] ||="",
      params[:area_ids] ||=""
    )

    @filter_count = 0
    if params[:tag_ids]
        tag_ids_array = params[:tag_ids]
        @tags_hash.each do |key, value|
            value.each do |tag|
                if tag_ids_array.include?(tag.id.to_s)
                    @filter_count += tag.gamaitems.size
                end
            end
        end
    end
    if params[:area_ids]
        area_ids_array = params[:area_ids]
        @areas.each do |area|
            if area_ids_array.include?(area.id.to_s)
               @filter_count += area.gamaitems.size 
            end
        end
    end
  end

end