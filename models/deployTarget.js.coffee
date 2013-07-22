class @DeployTarget extends MongoModel
  @collection: new Meteor.Collection "deploy_targets"

  addToQueue:      (user) -> @push 'user_queue', user
  removeFromQueue: (user) -> @pull 'user_queue', user

  HOUR: 1000 * 60 * 60
  DAY:  @HOUR * 24
  allowedHours: -> @attrs.allowedHours or QBConfig.reservationTime.defaultHours
  allowedTime:  -> @allowedHours() * @HOUR

  claimedTime:    -> @attrs.claimedAt.getTime()
  hoursRemaining: -> Math.round(@timeRemaining() / @HOUR)
  timeRemaining:  -> @attrs.timeRemaining
  updateTimeRemaining: ->
    tr = if @attrs.claimedAt? then @claimedTime() + @allowedTime() - (new Date) else null
    @update timeRemaining: tr
    tr
  checkTimeout: ->
    return false unless @owner()? and @attrs.claimedAt?
    if @updateTimeRemaining() <= 0
      oustedOwner = @owner()
      @unclaim()
      oustedOwner
    else
      false

  claim: (user) -> @updateUser user
  unclaim: ->
    currentQueue = @userQueue()
    newOwner = currentQueue.shift()
    if newOwner?
      @updateUser newOwner, user_queue: currentQueue
      newOwner
    else
      @updateUser '', claimedAt: null, hoursRemaining: null
      null
  updateUser: (user, options = {}) ->
    allAttrs = _.extend {cur_user: user, claimedAt: new Date, hoursRemaining: @allowedHours()}, options
    @update allAttrs
    @updateTimeRemaining()

  owner: -> if @attrs.cur_user?.length > 0 then @attrs.cur_user else null

  deployed: (attrs) -> @update attrs

  displayedAttrs: ->
    _.map @attrsForDisplay, (attr) =>
      name:   attr.displayName
      val:    if attr.display? then attr.display.apply(@) else @attrs[attr.dbName]
      dbName: attr.dbName
      fixed:  attr.fixed

  name: -> "#{@attrs.app}/#{@attrs.server}"

  queuePos: (user) -> @userQueue().indexOf(user) + 1

  linkToCommit: ->
    repoLink   = (App.findOne name: @attrs.app)?.repoLink()
    commitLink = @sha() or @ref()
    if repoLink? and commitLink? then "#{repoLink}/#{commitLink}" else null
  ref: -> if @attrs.ref?.length > 0 then @attrs.ref else null
  sha: -> if @attrs.commit?.sha?.length > 0 then @attrs.commit.sha else null

  userQueue: -> @attrs.user_queue || []


  @allEnvs: ->
    envs = []
    DeployTarget.all().forEach (dt) ->
      envs.push(dt.env) if dt.env? and envs.indexOf(dt.env) < 0
    envs.sort()

  @create: (attrs) ->
    attrs.server = DeployTarget._newServerName() unless attrs.server?
    DeployTarget.collection.insert attrs

  @_newServerName: ->
    newName = '[new server]'
    until DeployTarget.find(server: newName).length < 1
      newName = "[new server #{Math.floor(Math.random() * 100000)}]"
    newName


if Meteor.isServer
  Meteor.methods
    claimDeployTarget: (attrs) ->
      #TODO some form of security
      dt   = DeployTarget.findOne(_id: attrs.id)
      user = attrs.user
      dt.claim user
      Campfire.speak "#{dt.name()} claimed by #{user}"

    unclaimDeployTarget: (id) ->
      dt   = DeployTarget.findOne(_id: id)
      user = dt.attrs.cur_user
      newOwner = dt.unclaim()
      newOwnerText = if newOwner? then "reserved for #{newOwner}" else "free"
      Campfire.speak "#{dt.name()} released by #{user}; now #{newOwnerText}"

    queueUp: (attrs) ->
      dt   = DeployTarget.findOne(_id: attrs.id)
      user = attrs.user
      dt.addToQueue user
      Campfire.speak "#{user} queued up for #{dt.name()}"

    dequeue: (attrs) ->
      dt   = DeployTarget.findOne(_id: attrs.id)
      user = attrs.user
      dt.removeFromQueue user
      Campfire.speak "#{user} left queue for #{dt.name()}"
