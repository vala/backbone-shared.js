(function(){var __hasProp={}.hasOwnProperty,__extends=function(child,parent){for(var key in parent){if(__hasProp.call(parent,key))child[key]=parent[key]}function ctor(){this.constructor=child}ctor.prototype=parent.prototype;child.prototype=new ctor;child.__super__=parent.prototype;return child};Backbone.SharedModel=function(_super){__extends(SharedModel,_super);function SharedModel(attributes,options){SharedModel.__super__.constructor.call(this,attributes,options);this.doc=options&&options.doc;if(!this.collection){this.initializeSharing()}}SharedModel.prototype.initializeSharing=function(){var _this=this;if(this.collection){this.doc=this.collection.doc}if(this.sharedCollections){_.each(this.sharedCollections,function(collectionKey){return _this[collectionKey].initializeSharing({parent:_this,doc:_this.doc})})}if(this.sharedAttributes){_.each(this.sharedAttributesKeys,function(attr){return _this.on("change:"+attr,function(model,value){return _this.updateSharedAttr(attr,_this._previousAttributes[attr],value)})})}return this.on("destroy.share",this.destroyed,this)};SharedModel.prototype.updatePath=function(){if(this.collection){return this.collection.updatePath().concat([this.index])}else{return[]}};SharedModel.prototype.sharedAttributes=function(){return _.pick(this.attributes,this.sharedAttributesKeys)};SharedModel.prototype.destroy=function(options){if(options&&options.fromSharedOp){return SharedModel.__super__.destroy.call(this,options)}else{return this.trigger("destroy.share")}};SharedModel.prototype.updateSharedAttr=function(attr,old_value,value){return this.doc.submitOp([{p:this.updatePath().concat([attr]),od:old_value,oi:value}])};SharedModel.prototype.applySharedAction=function(actions){var _this=this;return _.each(actions,function(action){if(action.oi){_this.setAttribute(action)}if(action.ld){return _this.destroyModel(action)}})};SharedModel.prototype.setAttribute=function(action){var _this=this;return _.reduce(action.p,function(current,next){var node;if(_.isNumber(next)){return current.models[next]}else if(node=current[next]){return node}else{return current.set(next,action.oi)}},this)};SharedModel.prototype.destroyed=function(options){return this.doc.at(this.updatePath()).remove()};SharedModel.prototype.destroyModel=function(action){var model,_this=this;model=_.reduce(action.p,function(current,next){if(_.isNumber(next)){return current.models[next]}else{return current[next]}},this);return model.destroy({fromSharedOp:true})};return SharedModel}(Backbone.Model);Backbone.SharedCollection=function(_super){__extends(SharedCollection,_super);SharedCollection.prototype.path=null;function SharedCollection(models,options){var _this=this;SharedCollection.__super__.constructor.call(this,models,options);this.on("add destroy",function(){return _this.processIndexes()});this.on("add.share",function(model){return _this.modelAdded(model)})}SharedCollection.prototype.initializeSharing=function(options){var _this=this;this.parent=options.parent;this.setDoc(options.doc);this.processIndexes();return _.each(this.models,function(model){return model.initializeSharing()})};SharedCollection.prototype.setDoc=function(doc){var _this=this;this.doc=doc;this.subdoc=this.doc.at(this.updatePath());return this.subdoc.on("insert",function(pos,data){return _this.add(data,{fromSharedOp:true})})};SharedCollection.prototype.updatePath=function(){return this.parent.updatePath().concat([this.path])};SharedCollection.prototype.processIndexes=function(){var _this=this;return this.each(function(model,index){model.index=index;return model.trigger("indexed")})};SharedCollection.prototype.modelAdded=function(model){return this.subdoc.push(model.sharedAttributes())};SharedCollection.prototype.add=function(models,options){var triggerSharedAdd,_this=this;triggerSharedAdd=function(model,coll,opt){model.initializeSharing();if(!(options&&options.fromSharedOp)){return _this.trigger("add.share",model,coll,opt)}};this.on("add",triggerSharedAdd);SharedCollection.__super__.add.call(this,models,options);return this.off("add",triggerSharedAdd)};return SharedCollection}(Backbone.Collection)}).call(this);