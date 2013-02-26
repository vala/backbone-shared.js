# Models
class Project extends Backbone.SharedModel
  sharedAttributesKeys: ['title']
  sharedCollections: ['tracks']

  initialize: (project, options) ->
    @tracks = new TrackCollection(project.tracks, doc: options.doc)


class Track extends Backbone.SharedModel
  sharedAttributesKeys: ['title']
  sharedCollections: ['clips']

  initialize: (track, options) ->
    @clips = new ClipCollection(track.clips)


class Clip extends Backbone.SharedModel
  sharedAttributesKeys: ['position']

  initialize: (clip, option) ->

# Collections
class TrackCollection extends Backbone.SharedCollection
  path: 'tracks'
  model: Track

class ClipCollection extends Backbone.SharedCollection
  path: 'clips'
  model: Clip

# Views
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
    @model.on 'change:title', @titleChanged, @
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

  titleChanged : (model, title) ->
    @$el.find(".project-title").val(title)

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
    <input type='text' name='tracks[title][]' value='<%= title %>' class='track-title'>
    <a href='#' class='delete-track-btn'>Delete</a>
    <br>
  ")

  events:
    'keyup .track-title': 'updateTitle'
    'click .delete-track-btn': 'destroyTrack'


  initialize: ->
    @model = @options.model
    @container = $('#tracks')
    @model.on 'change:title', @titleChanged, @
    @model.on 'destroy', => @cleanView()

  render: ->
    unless @appended
      @$el.appendTo(@container)
      @appended = true
    @$el.html(@template(@model.attributes))

  titleChanged : (model, title) ->
    @$el.find(".track-title").val(title)

  updateTitle: (e) ->
    @model.set(title: e.currentTarget.value)

  destroyTrack: (e) ->
    @model.destroy()

  cleanView: ->
    @$el.remove()

window.Project = Project
window.ProjectView = ProjectView
