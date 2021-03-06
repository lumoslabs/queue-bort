_.extend Template.queues,
  title: -> "queue-bort"
  envs:  -> DeployTarget.allEnvs()


_.extend Template.deployTargetGroup,
  currentUser:   -> Meteor.user()
  groupName:     -> @toString()
  deployTargets: -> DeployTarget.collection.find {env: @toString()}, {sort: ['server']}

Template.deployTargetGroup.events
  'click .newDeployTarget': (e) -> DeployTarget.create env: @toString()


DT = (attrs) -> DeployTarget.findOne(_id: attrs._id)
MAX_COMMIT_MSG = 70

_.extend Template.deployTarget,
  claimClass: ->
    dt      = DT(@)
    curUser = Meteor.user()?.profile?.name
    if dt.isOwner(curUser)
      "unclaim"
    else if dt.owner()
      if curUser in dt.userQueue()
        "dequeue"
      else
        "queueUp"
    else
      "claim"
  claimText: ->
    texts =
      claim:   "CLAIM ME"
      unclaim: "UNCLAIM"
      dequeue: "Dequeue (##{DT(@).queuePos(Meteor.user().profile.name)} in line)"
      queueUp: "Get in line"
    texts[Template.deployTarget.claimClass.apply(@)]

  commitMsg: ->
    commit = DT(@).attrs.commit
    return '' unless commit?
    msg = "#{commit.author}: #{commit.msg}"
    if msg.length <= MAX_COMMIT_MSG then msg else msg[0..MAX_COMMIT_MSG - 1] + '...'

  currentUser: -> Meteor.user()

  divID: -> DTHelpers.DIV_ID @_id

  ownerInfo: ->
    dt = DT(@)
    if (owner = dt.owner())?
      ownerStr = "#{owner}"
      if tr = dt.timeRemaining()
        hours = dt.hoursRemaining()
        ownerStr += if tr < dt.HOUR
          " (< 1 hour remaining!!1)"
        else
          " (c. #{hours} hours remaining)"
      ownerStr
    else
      ''

  queueUsers:     -> DT(@).userQueue()
  queueExists:    -> DT(@).userQueue().length > 0

  releaseLink:    -> DT(@).linkToCommit()
  releaseDisplay: -> DT(@).ref() or DT(@).sha()

  userClaimClass: ->
    classes =
      claim:   'free'
      unclaim: 'owned-by-current'
      dequeue: 'owned-by-other'
      queueUp: 'owned-by-other'
    classes[Template.deployTarget.claimClass.apply(@)]

Template.deployTarget.events
  'click .claim':   -> Meteor.call 'queueUp', id: @_id, user: Meteor.user().profile.name
  'click .unclaim': -> Meteor.call 'dequeue', id: @_id, user: Meteor.user().profile.name
  'click .queueUp': -> Meteor.call 'queueUp', id: @_id, user: Meteor.user().profile.name
  'click .dequeue': -> Meteor.call 'dequeue', id: @_id, user: Meteor.user().profile.name

  'click .delete': ->
    deployTarget = DeployTarget.findOne(_id: @_id)
    deployTarget.destroy() if confirm "Delete #{deployTarget.name()}?"
