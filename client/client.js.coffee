_.extend Template.queues,
  title:      -> "queue-bort"
  queueLists: -> QueueList.all

_.extend Template.queueList,
  queueBoxes: -> _.map @queues, (q) => ql_id: @_id, title: q

Template.queueList.events
  'click .newQueue': (e) ->
    QueueList.find(@).addQueue()

Template.queueBox.events
  'click .delete': (e) ->
    QueueList.find(_id: @ql_id).removeQueue(@title) if confirm "Delete #{@title}?"
