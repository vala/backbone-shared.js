class Project extends Backbone.SharedModel
  sharedAttributes: ['title']

  initialize: (project) ->
    @tracks = new TrackCollection(project.tracks, parent: this)
    @set(title: project.title)

class TrackCollection extends Backbone.SharedCollection
  path: 'tracks'

  initialize: (tracks, options) ->
    @parent = options.parent
    @createChildren('tracks', tracks, Track)

class Track extends Backbone.SharedModel
  sharedAttributes: ['title']

  initialize: (track, options) ->
    @set(title: track.title)

window.Project = Project