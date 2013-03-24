_.extend Template.queues,
  title: -> "queue-bort"
  tags:  ->
    tags = []
    Queue.all().forEach (ql) ->
      tags.push(ql.tag) if ql.tag? and tags.indexOf(ql.tag) < 0
    tags

_.extend Template.queueGroup,
  groupName: -> @.toString()
  queues:    -> Queue.collection.find tag: @.toString()

Template.queueGroup.events
  'click .newQueue': (e) ->
    Queue.create tag: @.toString()

Template.queue.events
  'click .delete': (e) ->
    queue = Queue.findOne(_id: @_id)
    queue.destroy() if confirm "Delete #{queue.name()}?"
