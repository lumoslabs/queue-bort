class @DeployTarget
  constructor: (@attrs) ->

  addToQueue:      (user) -> @push 'user_queue', user
  removeFromQueue: (user) -> @pull 'user_queue', user

  destroy: ->
    DeployTarget.collection.remove @attrs._id

  displayedAttrs: ->
    _.map DeployTarget.attrsForDisplay, (attr) =>
      name:   attr.displayName
      val:    @attrs[attr.dbName]
      dbName: attr.dbName
      fixed:  attr.fixed

  name: -> "#{@attrs.app}/#{@attrs.server}"

  pull: (attr, val) -> @_mongoArrayUpdate '$pull', attr, val
  push: (attr, val) -> @_mongoArrayUpdate '$push', attr, val

  queuePos: (user) -> @userQueue().indexOf(user) + 1

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs
    _.extend @attrs, newAttrs

  userQueue: -> @attrs.user_queue || []

  _mongoArrayUpdate: (operator, attr, val) ->
    params = {}
    params[attr] = val
    mongoCmd = {}
    mongoCmd[operator] = params
    @_mongoUpdate mongoCmd
    @_reload attr

  _mongoUpdate: (params) ->
    DeployTarget.collection.update @attrs._id, params

  _reload: (attr) ->
    @attrs[attr] = DeployTarget.collection.findOne(@attrs._id)[attr]

  @collection: new Meteor.Collection "deploy_targets"

  @attrsForDisplay: [
    {displayName: 'SHA',            dbName: 'sha'                       },
    # {displayName: 'Tag / Ref',      dbName: 'release_tag'               },
    {displayName: 'In use by',      dbName: 'cur_user',      fixed: true}
  ]

  @attrsForConfig: [
    {displayName: 'Polling server', dbName: 'polling_server' },
    {displayName: 'Release path',   dbName: 'release_path'   }
  ]

  @all: ->
    DeployTarget.collection.find()

  @allEnvs: ->
    envs = []
    DeployTarget.all().forEach (dt) ->
      envs.push(dt.env) if dt.env? and envs.indexOf(dt.env) < 0
    envs.sort()

  @create: (attrs) ->
    attrs.server = DeployTarget._newServerName() unless attrs.server?
    DeployTarget.collection.insert attrs

  @each: (func) -> _.each DeployTarget.find({}), func

  @find: (attrs) ->
    _.map DeployTarget.collection.find(attrs).fetch(), (q) -> new DeployTarget(q)

  @findOne: (attrs) ->
    record = DeployTarget.collection.findOne attrs
    if record? then new DeployTarget(record) else null

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
      dt.update cur_user: ''
      Campfire.speak "#{dt.name()} released by #{user}"

    queueUp: (attrs) -> DeployTarget.findOne(_id: attrs.id).addToQueue      attrs.user
    dequeue: (attrs) -> DeployTarget.findOne(_id: attrs.id).removeFromQueue attrs.user
