Meteor.startup ->
  DeployTarget.all().observeChanges
    changed: (id, fields) -> Meteor.defer -> animateChange(id) if displayFieldsChanged(fields)

animateChange = (dtID) ->
  return unless jQuery.ui?

  Deps.flush()
  $dt = $("##{DTHelpers.DIV_ID dtID}")

  origBC = {borderColor:     $dt.css('border-color')}
  origBG = {backgroundColor: $dt.css('background-color')}

  $dt.css(borderColor:     'white').animate(origBC, duration: 2000, queue: false)
  $dt.css(backgroundColor: 'gray' ).animate(origBG, duration: 1000, queue: false)

DISPLAY_FIELDS = ['commit', 'cur_user', 'ref', 'user_queue']
displayFieldsChanged = (fields) ->
  (return true if a of fields) for a in DISPLAY_FIELDS
  false
