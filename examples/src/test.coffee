class Project extends Backbone.SharedModel
  sharedAttributes: ['title']

  initialize: (project) ->
    @tracks = new TrackCollection(project.tracks, parent: this)
    @set(title: project.title)


class Track extends Backbone.SharedModel
  sharedAttributes: ['title']

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
    @tracks = _.map @model.tracks.models, (track) =>
      new TrackView(model: track)

  render: ->
    @$el.html(@template(@model.attributes))
    unless @created
      console.log "tuff"
      _.each @tracks, (track) => track.render(this)
      @created = true

  updateTitle: (e) ->
    @model.set(title: e.currentTarget.value)


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
