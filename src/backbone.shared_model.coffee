class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    super(attributes, options)
    _.each @sharedAttributesKeys, (attr) =>
      @on "change:#{ attr }", (model, value) =>
        @updateSharedAttr(attr, @_previousAttributes[attr], value)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []

  sharedAttributes: ->
    _.pick(@attributes, @sharedAttributesKeys)

  updateSharedAttr: (attr, old_value, value) ->
    console.log "Submit op : ", @updatePath().concat([attr]), " - oi :", value
    window.doc.submitOp([
      p: @updatePath().concat([attr]),
      od: old_value,
      oi: value
    ])

  applySharedAction: (actions) ->
    _.each actions, (action) =>
      if action.oi
        @setAttribute(action)

  setAttribute: (action) ->
    _.reduce(
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

  insertModel: (action) ->
    _.reduce(
      action.p
      (current, next) =>
        switch
          when _.isNumber(next)
            if (model = current.models[next])
              model
            else
              current.add(action.li)
          when (node = current[next])
            node
      this
    )




