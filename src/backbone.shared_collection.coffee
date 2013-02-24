class Backbone.SharedCollection extends Backbone.Collection
  path: null
  constructor: (models, options) ->
    super(models, options)

    # Assign collection index to model
    @each (model, index) =>
      model.index = index

  updatePath: ->
    @parent.updatePath().concat([@path])
