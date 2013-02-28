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
    # If we have shared sub-collections, initialize them and setup
    # needed attributes
    if @sharedCollections
      _.each @sharedCollections, (collectionKey) =>
        collection = @[collectionKey]
        if collection
          @[collectionKey].initializeSharing(parent: this, doc: @doc)

    if @sharedAttributes
      _.each @sharedAttributesKeys, (attr) =>
        @on "change:#{ attr }", (model, value) =>
          @updateSharedAttr(attr, @_previousAttributes[attr], value)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []

  attrSubdoc: (attr) ->
    @doc.at @updatePath.concat([attr])

  sharedAttributes: ->
    _.pick(@attributes, @sharedAttributesKeys)

  destroy: (options) ->
    unless options && options.fromSharedOp
      @destroyed()

    super(options)

  updateSharedAttr: (attr, old_value, value) ->
    @attrSubdoc(attr).set(value)

  applySharedAction: (actions) ->
    _.each actions, (action) =>
      if action.oi
        @setAttribute(action)
      if action.ld
        @destroyModel(action)

  setAttribute: (action) ->
    pathMaxDepth = action.p.length - 1
    _.reduce(
      action.p
      (current, next, index) =>
        if _.isNumber(next)
          current.models[next]
        else
          node = current[next]
          isLastIndex = (index == pathMaxDepth)
          isSharedCollection = _.contains(current.sharedCollections, next)
          if isLastIndex && isSharedCollection
            node.reset(action.oi, silent: false, fromSharedOp: true)
          else if node
            node
          else
            current.set(next, action.oi)
      this
    )

  destroyed: (options) ->
    @doc.at(@updatePath()).remove()

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