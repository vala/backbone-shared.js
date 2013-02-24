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

window.Project = Project
