_.extend Template.queues,
  title: -> "queue-bort"
  tags:  ->
    tags = []
    Queue.all().forEach (ql) ->
      tags.push(ql.tag) if ql.tag? and tags.indexOf(ql.tag) < 0
    tags.sort()

_.extend Template.queueGroup,
  groupName: -> @.toString()
  queues:    -> Queue.collection.find tag: @.toString()

Template.queueGroup.events
  'click .newQueue': (e) ->
    Queue.create tag: @.toString()


_.extend Template.queue,
  attrs:   -> Queue.findOne(_id: @_id).displayedAttrs()
  editing: -> Session.equals 'editingQueueName', @_id

Template.queue.events
  'click .delete': (e) ->
    queue = Queue.findOne(_id: @_id)
    queue.destroy() if confirm "Delete #{queue.name()}?"

  'dblclick h4': (e, tmpl) ->
    Session.set 'editingQueueName', @_id
    Meteor.flush() # force DOM redraw, so we can focus the edit field
    Helpers.activateInput tmpl.find '.text-input'

Template.queue.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    Queue.findOne(_id: @_id).update(queueName: value) unless value.length <= 0
    Session.set 'editingQueueName', null
  cancel: ->
    Session.set 'editingQueueName', null


_.extend Template.queueAttr,
  attrName: -> @.name
  attrVal:  -> @.val
