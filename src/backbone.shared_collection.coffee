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
    @on "add.share", (model) => @modelAdded(model)

  # Get shareJS collection subdoc
  setDoc: (@doc) ->
    @subdoc = @doc.at(@updatePath())
    # Listen to ShareJS model insertions
    @subdoc.on "insert", (pos, data) => @add(data, fromSharedOp: true)

  updatePath: ->
    @parent.updatePath().concat([@path])

  processIndexes: ->
    @each (model, index) =>
      model.index = index
      model.trigger "indexed"

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
