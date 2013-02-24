class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    super(attributes, options)
    _.each @sharedAttributes, (attr) =>
      @on "change:#{ attr }", (model, value) =>
        @submitSharedAttr(attr, @_previousAttributes[attr], value)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []

  submitSharedAttr: (attr, old_value, value) ->
    console.log @updatePath().concat([attr])
    window.doc.submitOp([
      p: @updatePath().concat([attr]),
      od: old_value,
      oi: value
    ])

  applySharedAction: (actions) ->
    _.each actions, (action) =>
      object = _.reduce(
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



