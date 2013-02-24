class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    super(attributes, options)
    console.log attributes, options
    _.each @sharedAttributes, (attr) =>
      @on "change:#{ attr }", (model, value) =>
        @submitSharedAttr(attr, @_previousAttributes[attr], value)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@get('index')])
    else
      []

  submitSharedAttr: (attr, old_value, value) ->
    console.log @updatePath().concat([attr])
    # window.doc.submitOp([
    #   p: @updatePath().concat([attr]),
    #   od: old_value,
    #   oi: value
    # ])
