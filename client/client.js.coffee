Template.queues.helpers
  title: -> "queue-bort"
  tags:  ->
    tags = []
    Queue.all().forEach (ql) ->
      tags.push(ql.tag) if ql.tag? and tags.indexOf(ql.tag) < 0
    tags.sort()


Template.queueGroup.helpers
  groupName: -> @.toString()
  queues:    -> Queue.collection.find tag: @.toString()

Template.queueGroup.events
  'click .newQueue': (e) ->
    Queue.create tag: @.toString()


Template.queue.helpers
  attrs: ->
    _.map Queue.findOne(_id: @_id).displayedAttrs(), (a) => _.extend a, qid: @_id
  claimText:   -> "CLAIM ME" #TODO switch to "get in line" if there's a queue
  currentUser: -> Meteor.user()
  editing:     -> Session.equals 'editingQueueName', @_id

Template.queue.events
  'click .delete': (e) ->
    queue = Queue.findOne(_id: @_id)
    queue.destroy() if confirm "Delete #{queue.name()}?"

  'dblclick .name': (e, tmpl) ->
    if Meteor.userId()
      Session.set 'editingQueueName', @_id
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.queue.events Helpers.okCancelEvents '.queueName .text-input',
  ok: (value) ->
    Queue.findOne(_id: @_id).update(queueName: value) unless value.length <= 0
    Session.set 'editingQueueName', null
  cancel: ->
    Session.set 'editingQueueName', null


Template.queueAttr.helpers
  attrName:    -> @name
  attrVal:     -> @val
  editingAttr: -> Session.equals 'editingQueueAttr', "#{@qid}_#{@name}"

Template.queueAttr.events
  'dblclick': (e, tmpl) ->
    if Meteor.userId() and !@fixed
      Session.set 'editingQueueAttr', "#{@qid}_#{@name}"
      Meteor.flush() # force DOM redraw, so we can focus the edit field
      Helpers.activateInput tmpl.find '.text-input'

Template.queueAttr.events Helpers.okCancelEvents '.text-input',
  ok: (value) ->
    _.tap {}, (updateVals) =>
      updateVals[@dbName] = value
      Queue.findOne(_id: @qid).update(updateVals)
    Session.set 'editingQueueAttr', null
  cancel: ->
    Session.set 'editingQueueAttr', null
