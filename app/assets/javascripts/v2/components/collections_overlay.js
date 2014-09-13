/* global _, Vue, superagent */

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
    this.$on('requestShowCollectionOverlay', this.show);
    this.$on('requestHideCollectionOverlay', this.hide);

    this.$watch('activeWallpaper', this.fetchActiveWallpaperCollections);

    // this.$emit('collectionOverlayShow');
  },

  methods: {
    show: function (payload) {
      this.isVisible = true;

      if (_.isObject(payload) && payload.wallpaper) {
        this.activeWallpaper = payload.wallpaper;
      }

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
      this.activeWallpaper = null;
      this.$broadcast('resetCollectionState');
    },

    fetchCollections: function () {
      this.isLoading = true;
      this.isCollectionsLoaded = false;

      superagent
        .get('/api/v1/users/me/collections.json')
        .end(_.bind(function (res) {
          if (res.ok) {
            this.collections = res.body.collections;
          }
          this.isLoading = false;
          this.isCollectionsLoaded = true;
        }, this));
    },

    fetchActiveWallpaperCollections: function () {
      var self = this;

      if ( ! self.activeWallpaper) {
        // This shouldn't have happened
        return;
      }

      var actuallyFetch = function () {
        superagent
          .get('/api/v1/users/me/collections.json')
          .query({ wallpaper_id: self.activeWallpaper.id })
          .end(function (res) {
            if (res.ok) {
              console.log(self.collections);
              _.forEach(self.collections, function (collection) {
                collection.isInCollection = _.some(res.body.collections, { id: collection.id });
                if (collection.isInCollection) {
                  collection.isDraggedOver = false;
                }
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

    addWallpaperToCollection: function (wallpaper, collection) {
      var self = this;

      if ( ! wallpaper || ! collection) {
        return;
      }

      self.isHidingDeferred = true; // Defer hiding

      superagent
        .post('/api/v1/collections/' + collection.id + '/wallpapers.json')
        .send({ wallpaper_id: wallpaper.id })
        .end(function (res) {
          if (res.ok) {
            _.assign(collection, res.body.collection); // Refresh collection
            self.didAddWallpaperToCollection(wallpaper, collection);
          }
        });
    },

    didAddWallpaperToCollection: function (wallpaper, collection) {
      var self = this;

      // Handle deferred hiding
      if (self.isHidingDeferred) {
        setTimeout(function () {
          self.isHidingDeferred = false;
        }, 1000);
      }

      self.$dispatch('didAddWallpaperToCollection', {
        wallpaper: wallpaper,
        collection: collection
      });
    },

    onDragOver: function (e) {
      if ( ! e.targetVM.isInCollection) {
        e.preventDefault(); // prevent default to allow dropping
        e.targetVM.isDraggedOver = true;
      }
    },

    onDrop: function (e) {
      var wallpaperId = parseInt(e.dataTransfer.getData('text/x-wallpaper-id'));

      if (this.activeWallpaper.id === wallpaperId &&
           ! e.targetVM.isInCollection) {
        this.addWallpaperToCollection(this.activeWallpaper, e.targetVM);
      }

      e.targetVM.isDraggedOver = false;
    },

    onDropNewCollection: function (e) {
      e.preventDefault();

      var name = window.prompt('New collection name?', 'Untitled');
      if ( ! name) {
        return;
      }

      var wallpaper = this.activeWallpaper;
      this.isHidingDeferred = true;

      superagent
        .post('/api/v1/users/me/collections.json')
        .send({ name: name, public: true })
        .end(_.bind(function (res) {
          if (res.ok) {
            this.collections.unshift(res.body.collection);
            this.addWallpaperToCollection(wallpaper, res.body.collection);
          } else {
            this.isHidingDeferred = false;
            this.$dispatch('apiError', res);
          }
        }, this));
    }
  }
});
