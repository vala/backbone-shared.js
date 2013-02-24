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
      oi: value,
      type: 'setAttribute'
    ])

  applySharedAction: (actions) ->
    _.each actions, (action) =>
      @[action.type](action)

  setAttribute: (action) ->
    object = _.reduce(
      action.p
      (current, next) =>
        if _.isNumber(next)
          console.log "NUMBER"
          current.models[next]
        else if node = current[next]
          console.log "NODE"
          node
        else
          console.log "UPDATE VALUE"
          current.set(next, action.oi)
      this
    )



