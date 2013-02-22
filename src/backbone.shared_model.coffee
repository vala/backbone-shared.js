class Backbone.SharedModel extends Backbone.Model
  constructor: (attributes, options) ->
    _.each @sharedAttributes, (attr) =>
      @on "change:#{ attr }", =>
        @submitSharedAttr(attr, @_previousAttributes[attr], @get(attr))

    @index = options.index if options && (options.index || options.index == 0)

    super(attributes, options)

  updatePath: ->
    if @collection
      @collection.updatePath().concat([@index])
    else
      []


  submitSharedAttr: (attr, old_value, value) ->
    console.log @updatePath(), old_value, value
    # console.log([
    #   p: @updatePath().push(attr),
    #   od: old_value,
    #   oi: value
    # ])
