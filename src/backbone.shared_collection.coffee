class Backbone.SharedCollection extends Backbone.Collection
  path: null
  constructor: (models, options) ->
    @on "reset", =>
      console.log "Reset !"
      @models.each (model, index) =>
        model.index = index

    super(models, options)

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
