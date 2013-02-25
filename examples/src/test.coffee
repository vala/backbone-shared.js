class Project extends Backbone.SharedModel
  sharedAttributesKeys: ['title']

  initialize: (project) ->
    @tracks = new TrackCollection(project.tracks, parent: this)
    @set(title: project.title)


class Track extends Backbone.SharedModel
  sharedAttributesKeys: ['title']

  initialize: (track, options) ->
    @set(title: track.title)

class TrackCollection extends Backbone.SharedCollection
  path: 'tracks'
  model: Track

  initialize: (tracks, options) ->
    @parent = options.parent

class ProjectView extends Backbone.View
  el: $('#project')

  events:
    'keyup .project-title': 'updateTitle'

  created: false

  template: _.template("
    <input type='text' name='title' value='<%= title %>' class='project-title'>
  ")

  initialize: ->
    @model = @options.model
    @model.on 'change', => @render()
    @tracks = []
    # Build tracks view
    _.each @model.tracks.models, (track) => @trackAdded(track)
    # Tracks collection
    $('#add-track-btn').on 'click', => @addTrack()
    @model.tracks.on "add", (track) => @trackAdded(track)

  render: ->
    @$el.html(@template(@model.attributes))
    unless @created
      _.each @tracks, (track) => track.render(this)
      @created = true

  updateTitle: (e) ->
    @model.set(title: e.currentTarget.value)

  addTrack: ->
    @model.tracks.add([title: "New track"])

  trackAdded: (track) ->
    view = new TrackView(model: track)
    @tracks.push(view)
    view.render(this) if @created



class TrackView extends Backbone.View
  class: 'track'
  appended: false

  template: _.template("
    <input type='text' name='tracks[title][]' value='<%= title %>' class='track-title'><br>
  ")

  events:
    'keyup .track-title': 'updateTitle'

  initialize: ->
    @model = @options.model
    @container = $('#tracks')
    @model.on 'change', => @render()

  render: ->
    unless @appended
      @$el.appendTo(@container)
      @appended = true
    @$el.html(@template(@model.attributes))

  updateTitle: (e) ->
    @model.set(title: e.currentTarget.value)


window.Project = Project
window.ProjectView = ProjectView
