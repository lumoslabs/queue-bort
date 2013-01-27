_.extend Template.queues,
  title: ->
    "queue-bort"

  queueLists: ->
    QueueList.all
