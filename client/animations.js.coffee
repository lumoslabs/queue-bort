Meteor.startup ->
  DeployTarget.all().observeChanges
    changed: (id, fields) -> Meteor.defer -> animateChange(id)

animateChange = (dtID) ->
  return unless jQuery.ui?

  Deps.flush()
  $dt = $("##{DTHelpers.DIV_ID dtID}")

  origBC = {borderColor:     $dt.css('border-color')}
  origBG = {backgroundColor: $dt.css('background-color')}

  $dt.css(borderColor:     'white').animate(origBC, duration: 2000, queue: false)
  $dt.css(backgroundColor: 'gray' ).animate(origBG, duration: 1000, queue: false)
