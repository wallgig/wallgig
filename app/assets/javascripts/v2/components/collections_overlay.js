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
    var self = this;

    self.$on('wallpaperDragStart', function (wallpaper) {
      self.setActiveWallpaper(wallpaper);
      self.show();
    });
    self.$on('wallpaperDragEnd', self.hide);

    self.$watch('activeWallpaper', this.refreshActiveWallpaperCollectStatus);
    // this.$emit('collectionOverlayShow');
  },

  methods: {
    setActiveWallpaper: function (wallpaper) {
      this.activeWallpaper = wallpaper;
      this.$broadcast('setActiveWallpaper', wallpaper);
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
            self.$broadcast('setActiveWallpaper', self.activeWallpaper);
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
        }, 500);
      }

      self.$root.$broadcast('didAddWallpaperToCollection', {
        wallpaper: wallpaper,
        collection: collection
      });
    },

    onDrop: function (e) {
      e.preventDefault();

      var wallpaperId = parseInt(e.dataTransfer.getData('text/x-wallpaper-id'));

      if (this.activeWallpaper.id === wallpaperId &&
           ! e.targetVM.isInCollection) {
        this.addWallpaperToCollection(this.activeWallpaper, e.targetVM);
      }

      e.targetVM.isDraggedOver = false;
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
            self.addWallpaperToCollection(wallpaper, res.body.collection);
          } else {
            self.isHidingDeferred = false;
            self.$dispatch('apiError', res);
          }
        });
    }
  }
});
