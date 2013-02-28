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
    @parent = options.parent
    @setDoc(options.doc)
    @processIndexes()
    _.each @models, (model) =>
      model.initializeSharing()

  # Get shareJS collection subdoc
  setDoc: (doc = null) ->
    @doc = doc if doc
    @subdoc = @doc.at(@updatePath())

    try
      @subdoc.get()
      updatePath = @updatePath().join('-')
      unless @listening == updatePath
        @listening = updatePath
        # Listen to ShareJS model insertions
        @subdoc.on "insert", (pos, data) => @add(data, fromSharedOp: true)


  updatePath: ->
    @parent.updatePath().concat([@path])

  processIndexes: ->
    @each (model, index) =>
      model.index = index
      model.trigger "indexed"

  modelAdded: (model) ->
    if @subdoc.get() == undefined
      @subdoc.set([model.sharedAttributes()])
      @setDoc()
    else
      @subdoc.push(model.sharedAttributes())

  add: (models, options) ->

    # Enable shared collection to listen to
    triggerSharedAdd = (model, coll, opt) =>
      model.initializeSharing()
      unless options && options.fromSharedOp
        @modelAdded(model)

    @on "add", triggerSharedAdd
    super(models, options)
    @off "add", triggerSharedAdd

