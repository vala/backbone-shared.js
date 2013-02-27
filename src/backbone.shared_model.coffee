class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    super(attributes, options)
    @doc = options && options.doc
    # If we're on root node, we manually setup shared attributes on children
    # collections now that our objects are fully created
    @initializeSharing() unless @collection

  initializeSharing: ->
    # Set doc if not root node
    if @collection
      @doc = @collection.doc
      @subdoc = @doc.at(@updatePath())
    # If we have shared sub-collections, initialize them and setup
    # needed attributes
    if @sharedCollections
      _.each @sharedCollections, (collectionKey) =>
        @[collectionKey].initializeSharing(parent: this, doc: @doc)

    if @sharedAttributes
      _.each @sharedAttributesKeys, (attr) =>
        @on "change:#{ attr }", (model, value) =>
          @updateSharedAttr(attr, @_previousAttributes[attr], value)

    @on "destroy.share", (options) => @destroyed(options)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []

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
    model.destroy(fromSharedOp: true)



