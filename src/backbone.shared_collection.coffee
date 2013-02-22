class Backbone.SharedCollection extends Backbone.Collection
  path: null

  updatePath: ->
    @parent.updatePath().concat([@path])

  createChildren: (key, array, klass) ->
    this[key] = _.map array, (item, index) =>
      @instanciateChildren(klass, item, index: index, collection: this)

  instanciateChildren: (klass, attributes, options) ->
    f = ->
    f.prototype = klass.prototype
    o = new f()
    klass.call(o, attributes, options)
    o.constructor = klass
    o
