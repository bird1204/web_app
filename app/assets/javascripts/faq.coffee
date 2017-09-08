$ ->
  render = () ->
    $('.question-wrapper').click (event) ->
      $(this).find('.arrow-icon').toggle()
      $(this).find('.answer').slideToggle('fast')


  render()
