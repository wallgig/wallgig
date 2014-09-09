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

    this.$watch('activeWallpaper', function () {
      console.log(arguments);
    });
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
          console.log(this.collections);
        }
        this.isLoading = false;
        this.isCollectionsLoaded = true;
      }, this));
    },

    onDragEnter: function (collection, e) {
      collection.isHovering = true;
    },

    onDragLeave: function (collection, e) {
      collection.isHovering = false;
    },

    onDragOver: function (collection, e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
    },

    onDrop: function (collection, e) {
      e.preventDefault();
      collection.isHovering = false;

      console.log(this.activeWallpaper.id, ' dropped into ', collection.name)
    }
  }
});
