/* global _, Vue, superagent */

Vue.component('collections-overlay', {
  data: {
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
  },

  methods: {
    show: function () {
      this.visible = true;

      if ( ! this.isCollectionsLoaded) {
        this.fetchCollections();
      }
    },

    showWithWallpaper: function (wallpaper) {
      this.activeWallpaper = wallpaper;
      this.show();
    },

    hide: function () {
      this.visible = false;
      this.activeWallpaper = null;
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
        console.log('got', res.body);
        if (res.ok) {
          _.forEach(this.collections, function (collection) {
            collection.isInCollection = _.some(res.body.collections, { id: collection.id });
          });
        }
      }, this));
    },

    onDragEnter: function (e) {
      e.targetVM.isHovering = true;
    },

    onDragLeave: function (e) {
      e.targetVM.isHovering = false;
    },

    onDragOver: function (e) {
      e.preventDefault();
    },

    onDrop: function (e) {
      e.preventDefault();

      var wallpaperId = e.dataTransfer.getData('text/x-wallpaper-id');

      e.targetVM.isHovering = false;
    }
  }
});
