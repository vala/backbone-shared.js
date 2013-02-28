# Models
class Project extends Backbone.Model
  sharedAttributesKeys: ['title']
  sharedCollection: ['tracks']
  initialize: (project, options) ->
    @subdoc = options.subdoc
    @tracks = new TrackCollection(project.tracks, {subdoc: @subdoc})

class Track extends Backbone.Model
  sharedAttributesKeys: ['title']
  sharedCollections: ['clips']

  sharedAttributes: () ->
    _.pick @attributes, @sharedAttributesKeys

  initialize: (track, options) ->
    @index = options.collection.getNextIndex()
    @subdoc = options.collection.subdoc.at @index
    @subdoc.set({}) unless track.clips
    @clips = new ClipCollection(track.clips, {subdoc: @subdoc})

class Clip extends Backbone.Model
  sharedAttributesKeys: ['position']
  sharedAttributes: () ->
    _.pick @attributes, @sharedAttributesKeys

  initialise: (clip, options) ->
    @index = options.collection.getNextIndex()
    @subdoc = options.collection.subdoc.at @index

# Collections
class TrackCollection extends Backbone.Collection
  path: 'tracks'
  model: Track

  getNextIndex: ->
    @currentIndex++

  initialize: (models, options) ->
    @currentIndex = 0
    @subdoc = options.subdoc.at("tracks")
    console.log @subdoc
    @subdoc.set [] unless @subdoc.get()
    @subdoc.on "child op", (path, op) =>
      console.log "TrackCollection <- child op:", path, op
    @on "add", @trackAdded, this

  trackAdded: (model, collection, options) ->
    console.log "TrackCollection#trackAdded :", model, collection, options
    @subdoc.push model.sharedAttributes()

class ClipCollection extends Backbone.Collection
  path: 'clips'
  model: Clip

  getNextIndex: ->
    @currentIndex++

  initialize: (models, options) ->
    @currentIndex = 0
    @subdoc = options.subdoc.at("clips")
    @subdoc.set [] unless @subdoc.get()
    @subdoc.on "child op", (path, op) =>
      console.log "ClipCollection <- child op:", path, op
    @on "add", @clipAdded, this

  clipAdded: (model, collection, options) ->
    console.log "ClipCollection#clipAdded :", model, collection, options
    @subdoc.push model.sharedAttributes()

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
    @model.set(position: e.currentTarget.value)

  destroyClip: ->
    @model.destroy()

  cleanView: ->
    @$el.remove()




window.Project = Project
window.ProjectView = ProjectView
