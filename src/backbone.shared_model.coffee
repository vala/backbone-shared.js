class Backbone.SharedModel extends Backbone.Model

  # Allows initializing sharing on root node
  #
  constructor: (attributes, options) ->
    super(attributes, options)
    @doc = options?.doc
    # If we're on root node, we manually setup shared attributes on children
    # collections now that our objects are fully created
    @initializeSharing() unless @collection

  # Initializes sharing and related data setup
  #
  # It propagates to children collections and node
  # At document initialization, it is first handled by the root node so we
  # ensure that every attributes and handlers are built before launching
  # sharing
  #
  initializeSharing: ->
    # Set doc from parent collection if not root node
    @doc = @collection.doc if @collection

    # If we have shared sub-collections, initialize them and setup
    # needed attributes
    if @sharedCollections
      _.each @sharedCollections, (collectionKey) =>
        @[collectionKey]?.initializeSharing(parent: this, doc: @doc)

    # Listen changes on sharedAttributes to propagate them
    if @sharedAttributes
      _.each @sharedAttributesKeys, (attr) =>
        @on "change:#{ attr }", (model, value) =>
          @updateSharedAttr(attr, @_previousAttributes[attr], value)

    # Handle model destroy to be propagated to shared docs
    @on "destroy", @destroyed, this

  # Processes the current resource path in sharejs JSON doc by using its
  # parent collection path and its index
  #
  # If the model is the root node, then returns an empty array
  #
  sharePath: ->
    @collection?.sharePath().concat([@index]) || []

  # Dynamically fetches the current model's subdoc from it's current
  # sharejs path
  #
  subDoc: ->
    @doc.at(@sharePath())

  # Fetches the given attribute's subdoc
  #
  attrSubdoc: (attr) ->
    @subDoc().concat([attr])

  # Returns the hash of attributes, selecting only the ones that are shared
  #
  sharedAttributes: ->
    _.pick(@attributes, @sharedAttributesKeys)

  # Sends a shared action on the attribute's subdoc to dispatch its change
  # of value
  updateSharedAttr: (attr, old_value, value) ->
    @attrSubdoc(attr).set(value)

  # Calls sharejs to warn about the destroyed model
  # Ensures that the action was not called by sharejs itself to avoid destroy
  # loops
  #
  destroyed: (model, coll, options) ->
    unless options?.fromSharedOp
      @subDoc().remove()

  # Event handler which is called when a shared action comes from the remote
  # sharejs server.
  # Handles routing action depending on its purpose, which is first calculated
  # from the action key present
  #
  # Only used on root node
  #
  applySharedAction: (actions) ->
    _.each actions, (action) =>
      if action.li
        @insertModel(action)
      if action.oi
        @setAttributeOrCollection(action)
      if action.ld
        @destroyModel(action)

  # Fetches the resource in the current Backbone tree, being a model or a
  # collection, from the passed sharejs path array
  #
  resourceAt: (path) ->
    aux = (res, i) => if _.isNumber(i) then res.models[i] else res[i]
    _.reduce(path, aux, this)

  # Inserts a new model at the end of the target collection
  #
  insertModel: (action) ->
    coll = @resourceAt _.initial action.p
    coll.add(action.li, fromSharedOp: true)

  # Destroys the target model
  #
  destroyModel: (action) ->
    model = @resourceAt action.p
    model.destroy(fromSharedOp: true)

  # Handles two cases of shared ops
  # The first, reseting a given model's collection with a model
  # The second, setting the value of a shared attribute
  #
  setAttributeOrCollection: (action) ->
    # Get target model and the key we'll update on that model
    target = @resourceAt _.initial action.p
    key = _.last action.p

    # If key is a sharedCollection of target resource, the we'll reset it with
    # the given action.oi values
    if (coll = target[key]) && _.contains(target.sharedCollections, key)
      coll.reset(action.oi, silent: false, fromSharedOp: true)
    # Else, key is an attribute of target, so we update its value
    else
      target.set(key, action.oi)

