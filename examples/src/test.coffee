# Models
class Project extends Backbone.SharedModel
  sharedAttributesKeys: ['title']
  sharedCollections: ['tracks']

  initialize: (project, options) ->
    @tracks = new TrackCollection(project.tracks)


class Track extends Backbone.SharedModel
  sharedAttributesKeys: ['title']
  sharedCollections: ['clips']

  initialize: (track, options) ->
    @clips = new ClipCollection(track.clips)

class Clip extends Backbone.SharedModel
  sharedAttributesKeys: ['position']

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
    'click .add-track-btn': 'addTrack'

  created: false

  template: _.template("
    <h1>Project</h1>
    <input type='text' name='title' value='<%= title %>' class='project-title'>
    <button class='add-track-btn' type='button'>Add Track</button>
    <div class='tracks'></div>
  ")

  initialize: ->
    @model = @options.model
    @model.on 'change:title', @titleChanged, this
    # Tracks collection
    @model.tracks.on "add", (track) => @trackAdded(track)

  render: ->
    @$el.html(@template(@model.attributes))
    # Build tracks view
    @model.tracks.each @trackAdded, this
    this

  titleChanged : (model, title) ->
    @$el.find(".project-title").val(title)

  updateTitle: (e) ->
    @model.set(title: e.currentTarget.value)

  addTrack: ->
    @model.tracks.add([title: "New track"])

  trackAdded: (track) ->
    view = new TrackView(model: track)
    @$('.tracks').append(view.render().el)



class TrackView extends Backbone.View
  class: 'track'

  template: _.template("
    <h2>Track</h2>
    Title: <input type='text' name='tracks[title][]' value='<%= title %>' class='track-title'>
    <a href='#' class='delete-track-btn'>Delete</a>
    <button class='add-clip-btn' type='button'>Add Clip</button>
    <div class='clips'></div>
    <br>
  ")

  events:
    'keyup .track-title': 'updateTitle'
    'click .delete-track-btn': 'destroyTrack'
    'click .add-clip-btn': 'addClip'


  initialize: ->
    @container = $('#tracks')
    @model.on 'change:title', @titleChanged, this
    @model.on 'destroy', @cleanView, this
    @model.clips.on "add", @clipAdded, this

  render: ->
    @$el.html(@template(@model.attributes))
    @model.clips.each @clipAdded, this
    this

  titleChanged : (model, title) ->
    @$el.find(".track-title").val(title)

  updateTitle: (e) ->
    @model.set(title: e.currentTarget.value)

  destroyTrack: (e) ->
    @model.destroy()

  addClip: (e) ->
    @model.clips.add({ position: 0 })

  clipAdded: (clip) ->
    view = new ClipView(model: clip)
    @$('.clips').append(view.render().el)

  cleanView: ->
    @$el.remove()


class ClipView extends Backbone.View
  class: 'clip'

  template: _.template("
    Clip :
    <input type='number' name='clips[position][]' value='<%= position %>' class='clip-position'>
    <a href='#' class='delete-clip-btn'>Delete</a>
    <br>
  ")

  events:
    'keyup .clip-position': 'updatePosition'
    'click .delete-clip-btn': 'destroyClip'

  initialize: ->
    @model.on 'change:position', @positionChanged, this
    @model.on 'destroy', @cleanView, this

  render: (container) ->
    @$el.html(@template(@model.attributes))
    this

  positionChanged: (model, position) ->
    @$('.clip-position').val(position)

  updatePosition: (e) ->
    @model.set(position: parseInt(e.currentTarget.value, 10))

  destroyClip: ->
    @model.destroy()

  cleanView: ->
    @$el.remove()




window.Project = Project
window.ProjectView = ProjectView
