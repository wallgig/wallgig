/* global _, Vue, superagent */

Vue.component('collection', {
  data: {
    isDraggedOver: false,
    activeWallpaper: null,

    // Wallpaper states
    isInCollection: false,
    cachedWallpaperIds: [],

    id: null
  },

  created: function () {
    this.$watch('activeWallpaper', this.refreshCollectionState);
    this.$watch('cachedWallpaperIds', this.refreshCollectionState);
    this.$watch('isInCollection', function (value) {
      if (value && this.isDraggedOver) {
        this.isDraggedOver = false;
      }
    });

    this.$on('setActiveWallpaper', function (wallpaper) {
      this.activeWallpaper = wallpaper;
    });
    this.$on('wallpaperInCollections', this.wallpaperInCollections);
    this.$on('didAddWallpaperToCollection', this.didAddWallpaperToCollection);
  },

  methods: {
    refreshCollectionState: function () {
      if (this.activeWallpaper) {
        this.isInCollection = _(this.cachedWallpaperIds).contains(this.activeWallpaper.id);
      } else {
        this.isInCollection = false;
      }
    },

    wallpaperInCollections: function (data) {
      if (_(data.collectionIds).contains(this.id)) {
        // Wallpaper is in collection
        this.cachedWallpaperIds = _.chain(this.cachedWallpaperIds).
          push(data.wallpaperId).
          uniq().
          valueOf();
      } else {
        // Wallpaper not in collection, check if wallpaper id is cached and remove it
        this.cachedWallpaperIds = _.without(this.cachedWallpaperIds, data.wallpaperId);
      }
    },

    didAddWallpaperToCollection: function (data) {
      if (data.collection.id !== this.id) {
        // Not ours
        return;
      }

      this.cachedWallpaperIds = _.chain(this.cachedWallpaperIds).
        push(data.wallpaper.id).
        uniq().
        valueOf();
    },

    onDragEnter: function () {
      if ( ! this.isInCollection) {
        this.isDraggedOver = true;
      }
    },

    onDragLeave: function () {
      this.isDraggedOver = false;
    }
  }
});
