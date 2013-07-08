class @DeployTarget
  constructor: (@attrs) ->

  destroy: ->
    DeployTarget.collection.remove @attrs._id

  displayedAttrs: ->
    _.map DeployTarget.attrsForDisplay, (attr) =>
      name:   attr.displayName
      val:    @attrs[attr.dbName]
      dbName: attr.dbName
      fixed:  attr.fixed

  name: -> "#{@attrs.app}/#{@attrs.server}"

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs
    _.extend @attrs, newAttrs

  _mongoUpdate: (params) ->
    DeployTarget.collection.update @attrs._id, params

  @collection: new Meteor.Collection "deploy_targets"

  @attrsForDisplay: [
    {displayName: 'SHA',            dbName: 'sha'                       },
    {displayName: 'Tag / Ref',      dbName: 'release_tag'               },
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
