class Queue
  constructor: (@attrs) ->

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs

  _mongoUpdate: (params) ->
    Queue.collection.update @attrs._id, params

  @collection: new Meteor.Collection "queues"

  @all: ->
    Queue.collection.find()

  @create: (attrs) ->
    Queue.collection.insert attrs

  @find: (attrs) ->
    _.map Queue.collection.find(attrs).fetch(), (q) -> new Queue(q)

  @findOne: (attrs) ->
    new Queue(Queue.collection.findOne attrs)
