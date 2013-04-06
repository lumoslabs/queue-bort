class Server
  constructor: (@attrs) ->

  destroy: ->
    Server.collection.remove @attrs._id

  displayedAttrs: ->
    _.map Server.attrsForDisplay, (attr) =>
      name:   attr.displayName
      val:    @attrs[attr.dbName]
      dbName: attr.dbName
      fixed:  attr.fixed

  name: ->
    @attrs.serverName

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs

  _mongoUpdate: (params) ->
    Server.collection.update @attrs._id, params

  @collection: new Meteor.Collection "servers"

  @attrsForDisplay: [
    {displayName: 'SHA',       dbName: 'sha'                    },
    {displayName: 'Tag',       dbName: 'release_tag'            },
    {displayName: 'In use by', dbName: 'cur_user',   fixed: true}
  ]

  @all: ->
    Server.collection.find()

  @create: (attrs) ->
    attrs.serverName = Server._newServerName() unless attrs.serverName?
    Server.collection.insert attrs

  @find: (attrs) ->
    _.map Server.collection.find(attrs).fetch(), (q) -> new Server(q)

  @findOne: (attrs) ->
    new Server(Server.collection.findOne attrs)

  @_newServerName: ->
    newName = '[new server]'
    until Server.find(serverName: newName).length < 1
      newName = "[new server #{Math.floor(Math.random() * 100000)}]"
    newName
