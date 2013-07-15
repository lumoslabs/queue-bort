class @App
  constructor: (@attrs) ->

  repoLink: -> "#{@attrs.repo_link}/commits"

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs
    _.extend @attrs, newAttrs

  _mongoArrayUpdate: (operator, attr, val) ->
    params = {}
    params[attr] = val
    mongoCmd = {}
    mongoCmd[operator] = params
    @_mongoUpdate mongoCmd
    @_reload attr

  _mongoUpdate: (params) ->
    App.collection.update @attrs._id, params

  @collection: new Meteor.Collection "apps"

  @findOne: (attrs) ->
    record = App.collection.findOne attrs
    if record? then new App(record) else null
