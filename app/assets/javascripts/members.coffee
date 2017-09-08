$(document).on 'ready page:load change', (event) ->
  if window.location.pathname.match(/members\/signin/g) != null or window.location.pathname.match(/members\/signin_cart/g) != null
    window.checkFBLoginStatus = ->
      FB.getLoginStatus (response) ->
        if response.status == 'connected'
          $('input[name=email]').removeAttr 'required'
          $('input[name=password]').removeAttr 'required'
          $('#provider').val 'facebook'
          $('#facebook_token').val response.authResponse.accessToken
          $('#user_id').val response.authResponse.userID
          FB.api '/me', { fields: 'email' }, (userResponse) ->
            $.post '/members/invalidate', {
              email: userResponse.email
              provider: 'facebook'
              facebook_token: response.authResponse.accessToken
              user_id: response.authResponse.userID
            }, ((data) ->
              if data['message'] == false
                $('input[name=email]').val data['email']
                $('form').submit()
              else
                $('form').attr 'action', '/members/require_email'
                $('form').submit()
            ), 'json'
        else
          $('input[name=email]').attr 'required', true
          $('input[name=password]').attr 'required', true
          $('#provider').val 'direct'
          $('#facebook_token').val null
          $('#user_id').val null

  if window.location.pathname.match(/members\/edit/g) != null
    popover = (current, parent, dependent) ->
      if $(current).val() == null or $(current).val() == ''
        $('input[name=password]').removeAttr 'required'
        $('input[name=password]').parent().hide()
        $(parent).hide()
        $(current).removeAttr 'required'
        $(dependent).removeAttr 'required'
        $(dependent).val $(current).val()
      else
        $('input[name=password]').attr 'required', 'true'
        $('input[name=password]').parent().show()
        $(parent).show()
        $(current).attr 'required', true
        $(dependent).attr 'required', true

    $('input[name=new_email]').on 'change', ->
      $dependent = $('input[name=confirm-email]')
      popover $(this), $dependent.parent(), $dependent
    $('input[name=new_password]').on 'change', ->
      $dependent = $('input[name=confirm-password]')
      popover $(this), $dependent.parent(), $dependent