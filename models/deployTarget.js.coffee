class @DeployTarget extends MongoModel
  @collection: new Meteor.Collection "deploy_targets"

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

  addToQueue: (user) ->
    @push 'user_queue', user
    @updateTimeAttrs() if @isOwner(user)
  removeFromQueue: (user) ->
    oldOwner = @owner()
    @pull 'user_queue', user
    @updateTimeAttrs() unless oldOwner is @owner() # change of user?
  updateTimeAttrs: (options = {}) ->
    @update _.extend({claimedAt: new Date, hoursRemaining: @allowedHours()}, options)
    @updateTimeRemaining()

  deployed: (attrs) -> @update attrs

  isOwner: (user) -> @queuePos(user) == 0

  linkToCommit: ->
    repoLink   = (App.findOne name: @attrs.app)?.repoLink()
    commitLink = @sha() or @ref()
    if repoLink? and commitLink? then "#{repoLink}/#{commitLink}" else null
  ref: -> if @attrs.ref?.length > 0 then @attrs.ref else null
  sha: -> if @attrs.commit?.sha?.length > 0 then @attrs.commit.sha else null

  name: -> "#{@attrs.app}/#{@attrs.server}"

  owner: -> @_completeUserList()[0] or null

  queuePos: (user) -> @_completeUserList().indexOf(user)

  userQueue: -> @_completeUserList()[1..-1]

  _completeUserList: -> @attrs.user_queue or []


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
    queueUp: (attrs) ->
      dt   = DeployTarget.findOne(_id: attrs.id)
      user = attrs.user
      dt.addToQueue user
      Campfire.speak if dt.isOwner(user)
        "#{dt.name()} claimed by #{user}"
      else
        "#{user} queued up for #{dt.name()}"

    dequeue: (attrs) ->
      dt   = DeployTarget.findOne(_id: attrs.id)
      user = attrs.user
      wasOwner = dt.isOwner(user)
      dt.removeFromQueue user
      Campfire.speak if wasOwner
        newOwner = dt.owner()
        newOwnerText = if newOwner? then "reserved for #{newOwner}" else "free"
        "#{dt.name()} released by #{user}; now #{newOwnerText}"
      else
        "#{user} left queue for #{dt.name()}"
