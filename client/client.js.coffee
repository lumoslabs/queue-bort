_.extend Template.queues,
  title: -> "queue-bort"
  tags:  ->
    tags = []
    Queue.all().forEach (ql) ->
      tags.push(ql.tag) if ql.tag? and tags.indexOf(ql.tag) < 0
    tags

_.extend Template.queueGroup,
  groupName: -> @
  queues:    -> Queue.collection.find tag: @
  #queueBoxes: -> _.map @queues, (q) -> ql_id: @_id, title: q

Template.queueGroup.events
  'click .newQueue': (e) ->
    QueueList.find(@).addQueue()

Template.queue.events
  'click .delete': (e) ->
    #QueueList.find(_id: @ql_id).removeQueue(@title) if confirm "Delete #{@title}?"
    console.log "delete"
