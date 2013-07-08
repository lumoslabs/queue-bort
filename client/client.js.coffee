_.extend Template.queues,
  title: -> "queue-bort"
  envs:  -> DeployTarget.allEnvs()


_.extend Template.deployTargetGroup,
  currentUser:   -> Meteor.user()
  groupName:     -> @toString()
  deployTargets: -> DeployTarget.collection.find {env: @toString()}, {sort: ['server']}

Template.deployTargetGroup.events
  'click .newDeployTarget': (e) ->
    DeployTarget.create env: @toString()


_.extend Template.deployTarget,
  attrs: ->
    _.map DeployTarget.findOne(_id: @_id).displayedAttrs(), (a) => _.extend a, dtid: @_id
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
  'click .claim':   -> Meteor.call 'claimDeployTarget',   id: @_id, user: Meteor.user().profile.name
  'click .unclaim': -> Meteor.call 'unclaimDeployTarget', @_id
  'click .queueUp': -> console.log "implement queue"

  'click .delete': ->
    deployTarget = DeployTarget.findOne(_id: @_id)
    deployTarget.destroy() if confirm "Delete #{deployTarget.name()}?"

  'dblclick .name': (e, tmpl) ->
    if Meteor.userId()
      Session.set 'editingDeployTargetName', @_id
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.deployTarget.events Helpers.okCancelEvents '.server .text-input',
  ok: (value) ->
    DeployTarget.findOne(_id: @_id).update(server: value) unless value.length <= 0
    Session.set 'editingDeployTargetName', null
  cancel: ->
    Session.set 'editingDeployTargetName', null


_.extend Template.deployTargetAttr,
  attrName:    -> @name
  attrVal:     -> @val
  editingAttr: -> Session.equals 'editingDeployTargetAttr', "#{@dtid}_#{@name}"

Template.deployTargetAttr.events
  'dblclick': (e, tmpl) ->
    if Meteor.userId() and !@fixed
      Session.set 'editingDeployTargetAttr', "#{@dtid}_#{@name}"
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.deployTargetAttr.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    _.tap {}, (updateVals) =>
      updateVals[@dbName] = value
      DeployTarget.findOne(_id: @dtid).update(updateVals)
    Session.set 'editingDeployTargetAttr', null
  cancel: ->
    Session.set 'editingDeployTargetAttr', null
