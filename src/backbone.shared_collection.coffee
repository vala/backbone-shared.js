#
# A shared collection
#
class Backbone.SharedCollection extends Backbone.Collection
  path: null

  constructor: (models, options) ->
    super(models, options)
    # Reprocess array index each time a model is added
    @on "add destroy", => @processIndexes()
    # Listen an insertion to be shared
    @on "reset", => @setDoc()

  initializeSharing: (options) ->
    @on "add", @triggerSharedAdd, this
    @parent = options.parent
    @setDoc(options.doc)
    @processIndexes()
    isNewCollection = !@subDoc().get()
    _.each @models, (model) =>
      model.initializeSharing()
      @modelAdded(model) if isNewCollection

  subDoc : -> @doc.at @sharePath()

  # Get shareJS collection subDoc
  setDoc: (doc = null) ->
    @doc = doc if doc
    try
      @subDoc().get()
      sharePath = @sharePath().join('-')
      unless @listening == sharePath
        @listening = sharePath

  sharePath: ->
    @parent.sharePath().concat([@path])

  processIndexes: ->
    @each (model, index) =>
      model.index = index
      model.trigger "indexed"

  modelAdded: (model) ->
    if @subDoc().get() == undefined
      @subDoc().set([model.sharedAttributes()])
      @setDoc()
    else
      @subDoc().push(model.sharedAttributes())

  # Enable shared collection to listen to
  triggerSharedAdd : (model, coll, options) ->
    unless options && options.fromSharedOp
      @modelAdded(model)

    model.initializeSharing()


