/* global _, Vue, superagent */

Vue.component('collection', {
  data: {
    isDraggedOver: false,

    // Wallpaper states
    isInCollection: false,
    cachedCollectedWallpaperIds: [],

    id: null
  },

  created: function () {
    this.$on('resetCollectionState', this.resetState);
//    this.$parent.$watch('')
  },

  methods: {
    resetState: function () {
      this.isDraggedOver = false;
      this.isInCollection = false;
    },

    onDragEnter: function () {
      if (!this.isInCollection) {
        this.isDraggedOver = true;
      }
    },

    onDragLeave: function () {
      this.isDraggedOver = false;
    }
  }
});
