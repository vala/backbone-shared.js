class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    super(attributes, options)
    @doc = options.doc || options.collection.doc
    @on "indexed", => @indexed()
    @on "destroy.share", (options) => @destroyed(options)

    _.each @sharedAttributesKeys, (attr) =>
      @on "change:#{ attr }", (model, value) =>
        @updateSharedAttr(attr, @_previousAttributes[attr], value)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []

  indexed: ->
    @subdoc = @doc.at(@updatePath())

  sharedAttributes: ->
    _.pick(@attributes, @sharedAttributesKeys)

  destroy: (options) ->
    if options && options.fromSharedOp
      super(options)
    else
      @trigger('destroy.share')

  updateSharedAttr: (attr, old_value, value) ->
    @doc.submitOp([
      p: @updatePath().concat([attr]),
      od: old_value,
      oi: value
    ])

  applySharedAction: (actions) ->
    _.each actions, (action) =>
      if action.oi
        @setAttribute(action)
      if action.ld
        @destroyModel(action)

  setAttribute: (action) ->
    _.reduce(
      action.p
      (current, next) =>
        if _.isNumber(next)
          current.models[next]
        else if node = current[next]
          node
        else
          current.set(next, action.oi)
      this
    )

  destroyed: (options) ->
    @subdoc.remove()

  destroyModel: (action) ->
    model = _.reduce(
      action.p
      (current, next) =>
        if _.isNumber(next)
          current.models[next]
        else
          current[next]
      this
    )
    console.log "Destroy from shared action : ", action, model
    model.destroy(fromSharedOp: true)



