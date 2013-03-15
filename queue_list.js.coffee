class QueueList
  constructor: (@attrs) ->

  addQueue: (name) ->
    unless name?
      name = @_newQueueName()
    @_mongoUpdate $push: queues: name

  queues: ->
    @attrs.queues

  removeQueue: (name) ->
    @_mongoUpdate $pull: queues: name

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs

  _mongoUpdate: (params) ->
    QueueList.collection.update @attrs._id, params

  _newQueueName: ->
    newName = '[new queue]'
    until @queues().indexOf(newName) < 0
      newName = "[new queue #{Math.floor(Math.random() * 100000)}]"
    newName

  @collection: new Meteor.Collection "queue_lists"

  @all: ->
    QueueList.collection.find({}, {sort: {name: 1}})

  @create: (attrs) ->
    QueueList.collection.insert attrs

  @find: (attrs) ->
    new QueueList(QueueList.collection.findOne attrs)

  @last: (attrs) ->
    new QueueList(_.last QueueList.all().fetch())
