_.extend Template.queues,
  title: -> "queue-bort"
  tags:  ->
    tags = []
    DeployTarget.all().forEach (ql) ->
      tags.push(ql.tag) if ql.tag? and tags.indexOf(ql.tag) < 0
    tags.sort()


_.extend Template.deployTargetGroup,
  groupName:     -> @toString()
  deployTargets: -> DeployTarget.collection.find {tag: @toString()}, {sort: ['deployTargetName']}

Template.deployTargetGroup.events
  'click .newDeployTarget': (e) ->
    DeployTarget.create tag: @toString()


_.extend Template.deployTarget,
  attrs: ->
    _.map DeployTarget.findOne(_id: @_id).displayedAttrs(), (a) => _.extend a, sid: @_id
  claimClass: ->
    curOwner = DeployTarget.findOne(_id: @_id).attrs.cur_user
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
    texts[Template.deployTarget.claimClass.apply(@)]
  currentUser: -> Meteor.user()
  editing:     -> Session.equals 'editingDeployTargetName', @_id

Template.deployTarget.events
  'click .claim': ->
    DeployTarget.findOne(_id: @_id).update cur_user: Meteor.user().profile.name
  'click .unclaim': ->
    DeployTarget.findOne(_id: @_id).update cur_user: ''
  'click .queueUp': ->
    console.log "implement queue"

  'click .delete': ->
    deployTarget = DeployTarget.findOne(_id: @_id)
    deployTarget.destroy() if confirm "Delete #{deployTarget.name()}?"

  'dblclick .name': (e, tmpl) ->
    if Meteor.userId()
      Session.set 'editingDeployTargetName', @_id
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.deployTarget.events Helpers.okCancelEvents '.deployTargetName .text-input',
  ok: (value) ->
    DeployTarget.findOne(_id: @_id).update(deployTargetName: value) unless value.length <= 0
    Session.set 'editingDeployTargetName', null
  cancel: ->
    Session.set 'editingDeployTargetName', null


_.extend Template.deployTargetAttr,
  attrName:    -> @name
  attrVal:     -> @val
  editingAttr: -> Session.equals 'editingDeployTargetAttr', "#{@sid}_#{@name}"

Template.deployTargetAttr.events
  'dblclick': (e, tmpl) ->
    if Meteor.userId() and !@fixed
      Session.set 'editingDeployTargetAttr', "#{@sid}_#{@name}"
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.deployTargetAttr.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    _.tap {}, (updateVals) =>
      updateVals[@dbName] = value
      DeployTarget.findOne(_id: @sid).update(updateVals)
    Session.set 'editingDeployTargetAttr', null
  cancel: ->
    Session.set 'editingDeployTargetAttr', null
