class Queue
  constructor: (@attrs) ->

  destroy: ->
    Queue.collection.remove @attrs._id

  name: ->
    @attrs.queueName

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs

  _mongoUpdate: (params) ->
    Queue.collection.update @attrs._id, params

  @collection: new Meteor.Collection "queues"

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
