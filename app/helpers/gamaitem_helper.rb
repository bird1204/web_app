module GamaitemHelper
  def cover_reaction cover, image_size
    cover_content = JSON.parse cover['kcontent']
    case cover['kind']
    when '1'
      if cover_content['topic_id'].present?      
        render(
          partial: 'cover',
          locals: {
            pic_url: eval("#{image_size}_size(%Q(#{cover['pic_url']}))"),
            url: topic_path(id: cover_content['topic_id'])
          }
        )
      elsif cover_content['classification_id'].present?
        render(
          partial: 'cover',
          locals: {
            pic_url: eval("#{image_size}_size(%Q(#{cover['pic_url']}))"),
            url: classification_path(id: cover_content['classification_id'])
          }
        )
      end
    when '2'
      render(
        partial: 'cover',
        locals: {
          pic_url: eval("#{image_size}_size(%Q(#{cover['pic_url']}))"),
          url: gamaitem_path(id: cover_content['item_id'])
        }
      ) if cover_content['item_id'].present?
    when '3'
      render(
        partial: 'cover',
        locals: {
          pic_url: eval("#{image_size}_size(%Q(#{cover['pic_url']}))"),
          message: cover_content['message']
        }
      ) if cover_content['message'].present?
    end
  end
end
