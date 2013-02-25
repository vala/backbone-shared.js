// Generated by CoffeeScript 1.3.3
(function() {
  var Project, ProjectView, Track, TrackCollection, TrackView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Project = (function(_super) {

    __extends(Project, _super);

    function Project() {
      return Project.__super__.constructor.apply(this, arguments);
    }

    Project.prototype.sharedAttributesKeys = ['title'];

    Project.prototype.initialize = function(project) {
      this.tracks = new TrackCollection(project.tracks, {
        parent: this
      });
      return this.set({
        title: project.title
      });
    };

    return Project;

  })(Backbone.SharedModel);

  Track = (function(_super) {

    __extends(Track, _super);

    function Track() {
      return Track.__super__.constructor.apply(this, arguments);
    }

    Track.prototype.sharedAttributesKeys = ['title'];

    Track.prototype.initialize = function(track, options) {
      return this.set({
        title: track.title
      });
    };

    return Track;

  })(Backbone.SharedModel);

  TrackCollection = (function(_super) {

    __extends(TrackCollection, _super);

    function TrackCollection() {
      return TrackCollection.__super__.constructor.apply(this, arguments);
    }

    TrackCollection.prototype.path = 'tracks';

    TrackCollection.prototype.model = Track;

    TrackCollection.prototype.initialize = function(tracks, options) {
      return this.parent = options.parent;
    };

    return TrackCollection;

  })(Backbone.SharedCollection);

  ProjectView = (function(_super) {

    __extends(ProjectView, _super);

    function ProjectView() {
      return ProjectView.__super__.constructor.apply(this, arguments);
    }

    ProjectView.prototype.el = $('#project');

    ProjectView.prototype.events = {
      'keyup .project-title': 'updateTitle'
    };

    ProjectView.prototype.created = false;

    ProjectView.prototype.template = _.template("    <input type='text' name='title' value='<%= title %>' class='project-title'>  ");

    ProjectView.prototype.initialize = function() {
      var _this = this;
      this.model = this.options.model;
      this.model.on('change', function() {
        return _this.render();
      });
      this.tracks = [];
      _.each(this.model.tracks.models, function(track) {
        return _this.trackAdded(track);
      });
      $('#add-track-btn').on('click', function() {
        return _this.addTrack();
      });
      return this.model.tracks.on("add", function(track) {
        return _this.trackAdded(track);
      });
    };

    ProjectView.prototype.render = function() {
      var _this = this;
      this.$el.html(this.template(this.model.attributes));
      if (!this.created) {
        _.each(this.tracks, function(track) {
          return track.render(_this);
        });
        return this.created = true;
      }
    };

    ProjectView.prototype.updateTitle = function(e) {
      return this.model.set({
        title: e.currentTarget.value
      });
    };

    ProjectView.prototype.addTrack = function() {
      return this.model.tracks.add([
        {
          title: "New track"
        }
      ]);
    };

    ProjectView.prototype.trackAdded = function(track) {
      var view;
      view = new TrackView({
        model: track
      });
      this.tracks.push(view);
      if (this.created) {
        return view.render(this);
      }
    };

    return ProjectView;

  })(Backbone.View);

  TrackView = (function(_super) {

    __extends(TrackView, _super);

    function TrackView() {
      return TrackView.__super__.constructor.apply(this, arguments);
    }

    TrackView.prototype["class"] = 'track';

    TrackView.prototype.appended = false;

    TrackView.prototype.template = _.template("    <input type='text' name='tracks[title][]' value='<%= title %>' class='track-title'><br>  ");

    TrackView.prototype.events = {
      'keyup .track-title': 'updateTitle'
    };

    TrackView.prototype.initialize = function() {
      var _this = this;
      this.model = this.options.model;
      this.container = $('#tracks');
      return this.model.on('change', function() {
        return _this.render();
      });
    };

    TrackView.prototype.render = function() {
      if (!this.appended) {
        this.$el.appendTo(this.container);
        this.appended = true;
      }
      return this.$el.html(this.template(this.model.attributes));
    };

    TrackView.prototype.updateTitle = function(e) {
      return this.model.set({
        title: e.currentTarget.value
      });
    };

    return TrackView;

  })(Backbone.View);

  window.Project = Project;

  window.ProjectView = ProjectView;

}).call(this);
