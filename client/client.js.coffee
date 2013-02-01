_.extend Template.queues,
  title:      -> "queue-bort"
  queueLists: -> QueueList.all

_.extend Template.queueList,
  queueBoxes: -> _.map @queues, (q) -> ql_id: @_id, title: q
