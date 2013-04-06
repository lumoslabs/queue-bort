_.extend Template.queues,
  title: -> "queue-bort"
  tags:  ->
    tags = []
    Server.all().forEach (ql) ->
      tags.push(ql.tag) if ql.tag? and tags.indexOf(ql.tag) < 0
    tags.sort()


_.extend Template.serverGroup,
  groupName: -> @toString()
  servers:   -> Server.collection.find {tag: @toString()}, {sort: ['serverName']}

Template.serverGroup.events
  'click .newServer': (e) ->
    Server.create tag: @toString()


_.extend Template.server,
  attrs: ->
    _.map Server.findOne(_id: @_id).displayedAttrs(), (a) => _.extend a, sid: @_id
  claimClass: ->
    curOwner = Server.findOne(_id: @_id).attrs.cur_user
    if curOwner == Meteor.user().profile.name
      "unclaim"
    else if curOwner? and curOwner.length > 0
      "queueUp"
    else
      "claim"
  claimText: ->
    texts =
      claim:   "CLAIM ME"
      unclaim: "UNCLAIM"
      queueUp: "Get in line"
    texts[Template.server.claimClass.apply(@)]
  currentUser: -> Meteor.user()
  editing:     -> Session.equals 'editingServerName', @_id

Template.server.events
  'click .claim': ->
    Server.findOne(_id: @_id).update cur_user: Meteor.user().profile.name
  'click .unclaim': ->
    Server.findOne(_id: @_id).update cur_user: ''
  'click .queueUp': ->
    Server.findOne(_id: @_id).update cur_user: ''

  'click .delete': ->
    server = Server.findOne(_id: @_id)
    server.destroy() if confirm "Delete #{server.name()}?"

  'dblclick .name': (e, tmpl) ->
    if Meteor.userId()
      Session.set 'editingServerName', @_id
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.server.events Helpers.okCancelEvents '.serverName .text-input',
  ok: (value) ->
    Server.findOne(_id: @_id).update(serverName: value) unless value.length <= 0
    Session.set 'editingServerName', null
  cancel: ->
    Session.set 'editingServerName', null


_.extend Template.serverAttr,
  attrName:    -> @name
  attrVal:     -> @val
  editingAttr: -> Session.equals 'editingServerAttr', "#{@sid}_#{@name}"

Template.serverAttr.events
  'dblclick': (e, tmpl) ->
    if Meteor.userId() and !@fixed
      Session.set 'editingServerAttr', "#{@sid}_#{@name}"
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.serverAttr.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    _.tap {}, (updateVals) =>
      updateVals[@dbName] = value
      Server.findOne(_id: @sid).update(updateVals)
    Session.set 'editingServerAttr', null
  cancel: ->
    Session.set 'editingServerAttr', null
