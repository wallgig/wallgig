/* global _, Vue, superagent */

Vue.component('collections-overlay', {
  data: {
    isVisible: false,
    isLoading: false,
    isCollectionsLoaded: false,
    activeWallpaper: null,

    collections: []
  },

  ready: function () {
    this.$on('collectionOverlayShow', this.show);
    this.$on('collectionOverlayShowWithWallpaper', this.showWithWallpaper);
    this.$on('collectionOverlayHide', this.hide);

    this.$watch('activeWallpaper', this.fetchActiveWallpaperCollections);

    // this.$emit('collectionOverlayShow');
  },

  methods: {
    show: function () {
      this.isVisible = true;

      if ( ! this.isCollectionsLoaded) {
        this.fetchCollections();
      }
    },

    showWithWallpaper: function (wallpaper) {
      this.activeWallpaper = wallpaper;
      this.show();
    },

    hide: function () {
      this.isVisible = false;
      this.activeWallpaper = null;

      // Reset collection hover state
      _.forEach(this.collections, function (collection) {
         collection.isHovering = false;
      });
    },

    fetchCollections: function () {
      this.isLoading = true;
      this.isCollectionsLoaded = false;

      superagent
      .get('/api/v1/users/me/collections')
      .accept('json')
      .end(_.bind(function (res) {
        if (res.ok) {
          this.collections = res.body.collections;
        }
        this.isLoading = false;
        this.isCollectionsLoaded = true;
      }, this));
    },

    fetchActiveWallpaperCollections: function () {
      _.forEach(this.collections, function (collection) {
         collection.isInCollection = false;
      });

      if ( ! this.activeWallpaper) {
        return;
      }

      superagent
      .get('/api/v1/users/me/collections')
      .query({ wallpaper_id: this.activeWallpaper.id })
      .accept('json')
      .end(_.bind(function (res) {
        if (res.ok) {
          _.forEach(this.collections, function (collection) {
            collection.isInCollection = _.some(res.body.collections, { id: collection.id });
            if (collection.isInCollection) {
              collection.isHovering = false;
            }
          });
        }
      }, this));
    },

    addWallpaperToCollection: function (wallpaper, collection) {
      superagent
      .post('/api/v1/collections/' + collection.id + '/wallpapers')
      .send({ wallpaper_id: wallpaper.id })
      .accept('json')
      .end(_.bind(function (res) {
        // console.log('got', res);
        this.$dispatch('didAddWallpaperToCollection', {
          wallpaper: wallpaper,
          collection: collection
        });
      }, this));
    },

    onDragEnter: function (e) {
      if ( ! e.targetVM.isInCollection) {
        e.targetVM.isHovering = true;
      }
    },

    onDragLeave: function (e) {
      e.targetVM.isHovering = false;
    },

    onDragOver: function (e) {
      e.preventDefault();
    },

    onDrop: function (e) {
      e.preventDefault();

      var wallpaperId = parseInt(e.dataTransfer.getData('text/x-wallpaper-id'));

      console.log('this.activeWallpaper.id === wallpaperId', this.activeWallpaper.id === wallpaperId);
      console.log(' ! e.targetVM.isInCollection', ! e.targetVM.isInCollection);

      if (this.activeWallpaper.id === wallpaperId &&
           ! e.targetVM.isInCollection) {
        this.addWallpaperToCollection(this.activeWallpaper, e.targetVM);
      }

      e.targetVM.isHovering = false;
    }
  }
});
