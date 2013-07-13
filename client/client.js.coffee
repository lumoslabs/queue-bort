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
    dt      = DeployTarget.findOne(_id: @_id)
    dtOwner = dt.attrs.cur_user
    curUser = Meteor.user().profile.name
    if dtOwner == curUser
      "unclaim"
    else if dtOwner? and dtOwner.length > 0
      if curUser in dt.userQueue()
        "alreadyQueued"
      else
        "queueUp"
    else
      "claim"
  claimText: ->
    texts =
      claim:         "CLAIM ME"
      unclaim:       "UNCLAIM"
      alreadyQueued: "##{DeployTarget.findOne(_id: @_id).queuePos(Meteor.user().profile.name)} in line"
      queueUp:       "Get in line"
    texts[Template.deployTarget.claimClass.apply(@)]
  userClaimClass: ->
    classes =
      claim:         'free'
      unclaim:       'owned-by-current'
      alreadyQueued: 'owned-by-other'
      queueUp:       'owned-by-other'
    classes[Template.deployTarget.claimClass.apply(@)]

  currentUser:    -> Meteor.user()
  queueUsers:     -> DeployTarget.findOne(_id: @_id).userQueue()
  queueExists:    -> DeployTarget.findOne(_id: @_id).userQueue().length > 0

Template.deployTarget.events
  'click .claim':   -> Meteor.call 'claimDeployTarget',   id: @_id, user: Meteor.user().profile.name
  'click .unclaim': -> Meteor.call 'unclaimDeployTarget', @_id
  'click .queueUp': -> Meteor.call 'queueUp', id: @_id, user: Meteor.user().profile.name

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
