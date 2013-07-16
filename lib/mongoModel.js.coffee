class @Module
  @extend:  (obj) -> @[k]   = v for k, v of obj
  @include: (obj) -> @::[k] = v for k, v of obj

class @MongoModel
  @classProps:
    all: -> @collection.find()

    create: (attrs) -> @collection.insert attrs

    each: (func) -> _.each @find({}), func

    find: (attrs) -> _.map @collection.find(attrs).fetch(), (q) -> new @(q)

    findOne: (attrs) ->
      record = @collection.findOne attrs
      if record? then new @(record) else null

  @instanceProps:
    collection: -> @constructor.collection

    destroy: -> @collection().remove @attrs._id

    pull: (attr, val) -> @_mongoArrayUpdate '$pull', attr, val
    push: (attr, val) -> @_mongoArrayUpdate '$push', attr, val

    update: (newAttrs) ->
      @_mongoUpdate $set: newAttrs
      _.extend @attrs, newAttrs


    # PRIVATE
    _mongoArrayUpdate: (operator, attr, val) ->
      params = {}
      params[attr] = val
      mongoCmd = {}
      mongoCmd[operator] = params
      @_mongoUpdate mongoCmd
      @_reload attr

    _mongoUpdate: (params) -> @collection().update @attrs._id, params

    _reload: (attr) -> @attrs[attr] = @collection().findOne(@attrs._id)[attr]
