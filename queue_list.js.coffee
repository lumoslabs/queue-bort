class QueueList
  @collection: new Meteor.Collection "queue_lists"

  @all: -> QueueList.collection.find {}, sort: {name: 1}