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
  attrs:   ->
    _.map Queue.findOne(_id: @_id).displayedAttrs(), (a) => _.extend a, qid: @_id
  editing: -> Session.equals 'editingQueueName', @_id

Template.queue.events
  'click .delete': (e) ->
    queue = Queue.findOne(_id: @_id)
    queue.destroy() if confirm "Delete #{queue.name()}?"

  'dblclick .name': (e, tmpl) ->
    Session.set 'editingQueueName', @_id
    Meteor.flush() # force DOM redraw, so we can focus the edit field
    Helpers.activateInput tmpl.find '.text-input'

Template.queue.events Helpers.okCancelEvents '.queueName .text-input',
  ok: (value) ->
    Queue.findOne(_id: @_id).update(queueName: value) unless value.length <= 0
    Session.set 'editingQueueName', null
  cancel: ->
    Session.set 'editingQueueName', null


_.extend Template.queueAttr,
  attrName:    -> @name
  attrVal:     -> @val
  editingAttr: -> Session.equals 'editingQueueAttr', "#{@qid}_#{@name}"

Template.queueAttr.events
  'dblclick': (e, tmpl) ->
    Session.set 'editingQueueAttr', "#{@qid}_#{@name}"
    Meteor.flush() # force DOM redraw, so we can focus the edit field
    Helpers.activateInput tmpl.find '.text-input'

Template.queueAttr.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    _.tap {}, (updateVals) =>
      updateVals[@dbName] = value
      Queue.findOne(_id: @qid).update(updateVals) unless value.length <= 0
    Session.set 'editingQueueAttr', null
  cancel: ->
    Session.set 'editingQueueAttr', null
