_.extend Template.clickableInput,
  editing:       -> Session.equals Template.clickableInput.sessionVar(), @sessionVal()
  inputVal:      -> @[@varName]
  sessionVar:    -> "editing#{@sessionSuffix}"
  activateInput: (e, tmpl) =>
    if Meteor.userId() and tmpl.data.editable()
      Session.set Template.clickableInput.sessionVar(), tmpl.data.sessionVal()
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.clickableInput.events
  'dblclick .clickable-display': (e, tmpl) ->
    Template.clickableInput.activateInput(e, tmpl)

Template.clickableInput.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    @update(value)
    Session.set Template.clickableInput.sessionVar(), null
  cancel: ->
    Session.set Template.clickableInput.sessionVar(), null
