class Queue
  constructor: (@attrs) ->

  destroy: ->
    Queue.collection.remove @attrs._id

  displayedAttrs: ->
    _.map Queue.attrsForDisplay, (attr) =>
      name:   attr.displayName
      dbName: attr.dbName
      val:    @attrs[attr.dbName]

  name: ->
    @attrs.queueName

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs

  _mongoUpdate: (params) ->
    Queue.collection.update @attrs._id, params

  @collection: new Meteor.Collection "queues"

  @attrsForDisplay: [
    {displayName: 'SHA',       dbName: 'sha'},
    {displayName: 'Tag',       dbName: 'release_tag'},
    {displayName: 'In use by', dbName: 'cur_user'}
  ]

  @all: ->
    Queue.collection.find()

  @create: (attrs) ->
    attrs.queueName = Queue._newQueueName() unless attrs.queueName?
    Queue.collection.insert attrs

  @find: (attrs) ->
    _.map Queue.collection.find(attrs).fetch(), (q) -> new Queue(q)

  @findOne: (attrs) ->
    new Queue(Queue.collection.findOne attrs)

  @_newQueueName: ->
    newName = '[new queue]'
    until Queue.find(queueName: newName).length < 1
      newName = "[new queue #{Math.floor(Math.random() * 100000)}]"
    newName
