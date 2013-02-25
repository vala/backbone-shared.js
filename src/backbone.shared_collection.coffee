class Backbone.SharedCollection extends Backbone.Collection
  path: null

  constructor: (models, options) ->
    super(models, options)
    # Process indexes
    @processIndexes()
    # Reprocess array index each time a model is added
    @on "add", => @processIndexes()
    # Get shareJS collection subdoc
    @subdoc = window.doc.at(@updatePath())
    # Listen an insertion to be shared
    @on "add.share", (model) => @modelAdded(model)
    # Listen to ShareJS model insertions
    @subdoc.on "insert", (pos, data) => @add(data, fromSharedOp: true)

  updatePath: ->
    @parent.updatePath().concat([@path])

  processIndexes: ->
    @each (model, index) => model.index = index

  modelAdded: (model) ->
    @subdoc.push(model.sharedAttributes())

  add: (models, options) ->
    # Enable shared collection to listen to
    triggerSharedAdd = (model, coll, opt) =>
      unless options && options.fromSharedOp
        @trigger('add.share', model, coll, opt)

    @on "add", triggerSharedAdd
    super(models, options)
    @off "add", triggerSharedAdd