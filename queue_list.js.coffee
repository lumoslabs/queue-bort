class QueueList
  constructor: (@attrs) ->

  addQueue: (name) ->
    @_mongoUpdate $push: queues: name

  removeQueue: (name) ->
    @_mongoUpdate $pull: queues: name

  update: (newAttrs) ->
    @_mongoUpdate $set: newAttrs

  _mongoUpdate: (params) ->
    QueueList.collection.update @attrs._id, params

  @collection: new Meteor.Collection "queue_lists"

  @all: ->
    QueueList.collection.find({}, {sort: {name: 1}})

  @create: (attrs) ->
    QueueList.collection.insert attrs

  @find: (attrs) ->
    new QueueList(QueueList.collection.findOne attrs)

  @last: (attrs) ->
    new QueueList(_.last QueueList.all().fetch())
