class QueueList
  constructor: (@attrs) ->

  update: (newAttrs) ->
    QueueList.collection.update @attrs._id, $set: newAttrs

  @collection: new Meteor.Collection "queue_lists"

  @all: ->
    QueueList.collection.find {}, sort: {name: 1}

  @create: (attrs) ->
    QueueList.collection.insert attrs

  @find: (attrs) ->
    new QueueList(QueueList.collection.findOne attrs)
