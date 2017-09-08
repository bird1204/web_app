$(document).on 'ready page:load change', (event) ->
  $("#s3-uploader").S3Uploader
    additional_data: {'Content-type': 'image/png,image/gif,image/jpeg'}

  $('#s3-uploader').bind "s3_upload_failed", (e, content) ->
    console.error("#{content.filename} failed to upload : #{content.error_thrown}")

  $('#s3-uploader').bind "ajax:success", (e, data) ->
    url = decodeURIComponent(data.url.replace("https://jumplifespace.s3.amazonaws.com", "https://d2gfbj96l0a5kh.cloudfront.net"))
    $member_service_comment_image_urls = $('#member_service_images_url')
    $('#gallery').append '<img src='+url+'>'
    if $member_service_comment_image_urls.val() == null || $member_service_comment_image_urls.val() == ''
      $member_service_comment_image_urls.val url
    else
      $member_service_comment_image_urls.val $member_service_comment_image_urls.val() + ',' + url

  $('#submit-btn').on 'click', () ->
      $('#new_member_service').submit()