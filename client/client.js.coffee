_.extend Template.queues,
  title: ->
    "queue-bort"

  queueLists: ->
    QueueLists.find {}, sort: {name: 1}
