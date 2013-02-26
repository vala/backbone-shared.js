class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    super(attributes, options)
    @doc = options.doc
    @on "destroy.share", (options) => @destroyed(options)

    # If we're on root node, we manually setup shared attributes on children
    # collections now that our objects are fully created
    @initializeSubTree() unless @collection

    _.each @sharedAttributesKeys, (attr) =>
      @on "change:#{ attr }", (model, value) =>
        @updateSharedAttr(attr, @_previousAttributes[attr], value)

  initializeSubTree: ->
    # Set doc if not root node
    if @collection
      @doc = @collection.doc
      @subdoc = @doc.at(@updatePath())
    # If we have shared sub-collections, initialize them and setup
    # needed attributes
    if @sharedCollections && @sharedCollections.length > 0
      _.each @sharedCollections, (collectionKey) =>
        collection = @[collectionKey]
        collection.parent = this
        collection.setDoc(@doc)
        collection.processIndexes()
        _.each collection.models, (model) =>
          model.initializeSubTree()

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



