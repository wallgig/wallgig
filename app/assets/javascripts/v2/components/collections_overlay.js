(function (Vue, _, superagent) {
  var ADD_TO_COLLECTION_HIDE_TIMER = 500;

  Vue.component('collections-overlay', {
    data: {
      isVisible: false,
      isLoading: false,
      isCollectionsLoaded: false,
      isHidingDeferred: false,
      activeWallpaper: null,

      collections: []
    },

    ready: function () {
      this.$on('wallpaperDidStartDragging', this.wallpaperDidStartDragging)
      this.$on('wallpaperDidStopDragging', this.wallpaperDidStopDragging);

      this.$watch('activeWallpaper', this.activeWallpaperDidChange);
    },

    methods: {
      wallpaperDidStartDragging: function (wallpaper) {
        this.setActiveWallpaper(wallpaper);
        this.show();
      },

      wallpaperDidStopDragging: function (wallpaper) {
        this.hide();
      },

      activeWallpaperDidChange: function (wallpaper) {
        this.refreshActiveWallpaperCollectStatus(wallpaper);
      },

      setActiveWallpaper: function (wallpaper) {
        this.activeWallpaper = wallpaper;
        this.$broadcast('activeWallpaperDidChange', wallpaper); // TODO move to root?
      },

      show: function () {
        this.isVisible = true;

        if ( ! this.isCollectionsLoaded) {
          this.fetchCollections();
        }
      },

      hide: function () {
        var self = this;
        if (self.isHidingDeferred) {
          self.$watch('isHidingDeferred', function (value) {
            if (value) {
              return;
            }
            self.$unwatch('isHidingDeferred');
            self.hideNow();
          });
        } else {
          self.hideNow();
        }
      },

      hideNow: function () {
        this.isVisible = false;
        this.isHidingDeferred = false;
        this.setActiveWallpaper(null);
      },

      fetchCollections: function () {
        var self = this;
        self.isLoading = true;
        self.isCollectionsLoaded = false;

        superagent
          .get('/api/v1/users/me/collections.json')
          .end(function (res) {
            if (res.ok) {
              self.collections = res.body.collections;
            }
            self.isLoading = false;
            self.isCollectionsLoaded = true;

            Vue.nextTick(function () {
              self.$broadcast('activeWallpaperDidChange', self.activeWallpaper);
            });
          });
      },

      refreshActiveWallpaperCollectStatus: function () {
        var self = this;

        if ( ! self.activeWallpaper) {
          return;
        }

        var wallpaper = self.activeWallpaper;

        var actuallyFetch = function () {
          superagent
            .get('/api/v1/users/me/collections.json')
            .query({ wallpaper_id: wallpaper.id })
            .end(function (res) {
              if (res.ok) {
                _(res.body.collections).forEach(function (latestCollection) {
                  _.chain(self.collections).
                    find({ id: latestCollection.id }).
                    assign(latestCollection);
                });
                self.$broadcast('wallpaperInCollections', {
                  wallpaperId: wallpaper.id,
                  collectionIds: _.pluck(res.body.collections, 'id')
                });
              }
            });
        };

        if (self.isCollectionsLoaded) {
          actuallyFetch();
        } else {
          self.$watch('isCollectionsLoaded', function (value) {
            if ( ! value) {
              return;
            }
            self.$unwatch('isCollectionsLoaded');
            actuallyFetch();
          });
        }
      },

      wallpaperWillAddToCollection: function (wallpaper, collection) {
        var self = this;

        if ( ! wallpaper || ! collection) {
          return;
        }

        self.$root.$broadcast('wallpaperWillAddToCollection', wallpaper, collection);

        self.isHidingDeferred = true; // Defer hiding

        superagent
          .post('/api/v1/collections/' + collection.id + '/wallpapers.json')
          .send({ wallpaper_id: wallpaper.id })
          .end(function (res) {
            if (res.ok) {
              _.assign(collection, res.body.collection); // Refresh collection
              self.wallpaperDidAddToCollection(wallpaper, collection);
            }
          });
      },

      wallpaperDidAddToCollection: function (wallpaper, collection) {
        var self = this;

        // Handle deferred hiding
        if (self.isHidingDeferred) {
          setTimeout(function () {
            self.isHidingDeferred = false;
          }, ADD_TO_COLLECTION_HIDE_TIMER);
        }

        self.$root.$broadcast('wallpaperDidAddToCollection', wallpaper, collection);
      },

      onDrop: function (e) {
        e.preventDefault();

        var wallpaperId = parseInt(e.dataTransfer.getData('text/x-wallpaper-id'));
        var collection = e.targetVM;

        if (this.activeWallpaper.id === wallpaperId && ! collection.isInCollection) {
          this.wallpaperWillAddToCollection(this.activeWallpaper, collection);
        }
      },

      onDropNewCollection: function (e) {
        e.preventDefault();

        var self = this;
        self.isHidingDeferred = true;

        var name = window.prompt('New collection name?', 'Untitled');
        if ( ! name) {
          self.isHidingDeferred = false;
          return;
        }

        var wallpaper = self.activeWallpaper;

        superagent
          .post('/api/v1/users/me/collections.json')
          .send({ name: name, public: true })
          .end(function (res) {
            if (res.ok) {
              self.collections.unshift(res.body.collection);
              self.wallpaperWillAddToCollection(wallpaper, res.body.collection);
            } else {
              self.isHidingDeferred = false;
              self.$dispatch('apiError', res);
            }
          });
      }
    }
  });
})(Vue, _, superagent);
