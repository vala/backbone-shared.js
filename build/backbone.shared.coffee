class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    _.each @sharedAttributes, (attr) =>
      @on "change:#{ attr }", =>
        @submitSharedAttr(attr, @_previousAttributes[attr], @get(attr))

    @index = options.index if options && (options.index || options.index == 0)

    super(attributes, options)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []


  submitSharedAttr: (attr, old_value, value) ->
    console.log @updatePath(), old_value, value
    # console.log([
    #   p: @updatePath().push(attr),
    #   od: old_value,
    #   oi: value
    # ])


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
