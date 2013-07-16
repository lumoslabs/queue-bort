class @DeployTarget extends Module
  @extend  MongoModel.classProps
  @include MongoModel.instanceProps
  constructor: (@attrs) ->

  addToQueue:      (user) -> @push 'user_queue', user
  removeFromQueue: (user) -> @pull 'user_queue', user
  unclaim: ->
    currentQueue = @userQueue()
    newOwner = currentQueue.shift()
    if newOwner?
      @update cur_user: newOwner, user_queue: currentQueue
      newOwner
    else
      @update cur_user: ''
      null

  deployed: (sha) -> @update sha: sha

  displayedAttrs: ->
    _.map DeployTarget.attrsForDisplay, (attr) =>
      name:   attr.displayName
      val:    @attrs[attr.dbName]
      dbName: attr.dbName
      fixed:  attr.fixed

  name: -> "#{@attrs.app}/#{@attrs.server}"

  queuePos: (user) -> @userQueue().indexOf(user) + 1

  repoLink: -> (App.findOne name: @attrs.app)?.repoLink()

  userQueue: -> @attrs.user_queue || []

  @collection: new Meteor.Collection "deploy_targets"

  @attrsForDisplay: [
    {displayName: 'Release',        dbName: 'sha'                       },
    {displayName: 'In use by',      dbName: 'cur_user',      fixed: true}
  ]

  @attrsForConfig: [
    {displayName: 'Polling server', dbName: 'polling_server' },
    {displayName: 'Release path',   dbName: 'release_path'   }
  ]

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
      dt.update cur_user: user
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
