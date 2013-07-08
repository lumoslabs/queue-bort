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

  clickVarsForServer: -> _.extend @,
    sessionSuffix: 'ServerName'
    varName:       'server'
    editable:   -> true
    sessionVal: -> @_id
    update:     (val) -> DeployTarget.findOne(_id: @_id).update(server: val) unless val.length <= 0

Template.deployTarget.events
  'click .claim':   -> Meteor.call 'claimDeployTarget',   id: @_id, user: Meteor.user().profile.name
  'click .unclaim': -> Meteor.call 'unclaimDeployTarget', @_id
  'click .queueUp': -> console.log "implement queue"

  'click .delete': ->
    deployTarget = DeployTarget.findOne(_id: @_id)
    deployTarget.destroy() if confirm "Delete #{deployTarget.name()}?"


_.extend Template.deployTargetAttr,
  attrName: -> @name

  clickVarsForAttr: -> _.extend @,
    sessionSuffix: 'DeployTargetAttr'
    varName:       'val'
    editable:   -> !@fixed
    sessionVal: -> "#{@dtid}_#{@name}"
    update: (val) ->
      updateVals = {}
      updateVals[@dbName] = val
      DeployTarget.findOne(_id: @dtid).update(updateVals)

Template.deployTargetAttr.events
  'dblclick': (e, tmpl) -> Template.clickableInput.activateInput(e, tmpl)
