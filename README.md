# Backbone Shared

This library is an attempt to implement a subset of [Share.js](http://sharejs.org/)' [JSON API](https://github.com/josephg/ShareJS/wiki/JSON-Client-API) to work easily with [Backbone.js](http://backbonejs.org/), while keeping the latter's flexibility and without modifying its API.

## Usage

The only thing you should need to implement in your Backbone app, is subclassing `Backbone.SharedModel` instead of `Backbone.Model` and `Backbone.SharedCollection` instead of `Backbone.Collection`, and defining which attributes and collections you'll want to share.

This allows you not to think too much about how things are shared and being able to keep some attributes in your model that you want to be custom for each share.js client.

If you want an extensive example on how to us this lib, you may want to look at the [example client](https://github.com/vala/backbone-shared.js/tree/master/examples)

Here you have a simple example with only the Models and Collections setup :

```coffeescript
class Project extends Backbone.SharedModel
  sharedAttributesKeys: ['title']
  sharedCollections: ['tracks']

  initialize: (project, options) ->
    @tracks = new TrackCollection(project.tracks)

class Track extends Backbone.SharedModel
  sharedAttributesKeys: ['title']

class TrackCollection extends Backbone.SharedCollection
  path: 'tracks'
  model: Track
```

Now Let's say you initialize your Project model with the following :

```coffeescript
project = new Project(
  title: 'New Project',
  tracks: [
    { title: "Track 1" }
    { title: "Track 2" }
  ]
)
```

You'll be able to edit models and get them updated to other connected clients :

```coffeescript
# Client 1 :
project.tracks.models[0].set(title: "New track name")
# Client 2 :
project.tracks.models[0].get('title') # => "New track name"
```

That's all ...

## Running the example server

You'll need to have [CoffeeScript](http://coffeescript.org/) installed in order to run the example server.

For now, no `npm` package is provided, so you should clone this Github repo :

```bash
git clone git@github.com:vala/backbone-shared.js
```

Then you can `cd` into the cloned repo and run the server (which will watch all sources updates and recompile to appropriate js files) :

```bash
cake run:dev
```

You can now access the server at `http://localhost:8000/`

## Contributing

You can contribute in many ways :

* Feature requests and implementation
* Writing tests ...
* Implementing it and giving us some feedback
* Documenting
* Adding examples
* etc.

If you want to contribute to the codebase, just :

* Fork the project
* Make a topic branch
* Commit your changes
* Pull request !

## Licence

This project is licensed under the MIT Licence