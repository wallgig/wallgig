//= require lodash
//= require query-string
//= require vue
//= require superagent
//= require_tree ./components/.
//= require_self

/* global _, Vue, superagent */

(function (exports) {
  exports.app = new Vue({
    el: '#wallgig-app',

    paramAttributes: ['settings'],

    created: function () {
      var that = this;

      if (this.settings) {
        this.settings = JSON.parse(this.settings);
      }

      // API
      this.$on('apiError', this.handleApiError);

      // Wallpaper
      this.$on('wallpaperDragStart', function (wallpaper) {
        that.$broadcast('requestShowCollectionOverlay', { wallpaper: wallpaper });
      });
      this.$on('wallpaperDragEnd', function () {
        that.$broadcast('requestHideCollectionOverlay');
      });
    },

    methods: {
      handleApiError: function (res) {
        if (res.unauthorized) {
          if (res.body.message) {
            alert(res.body.message);
          } else {
            alert('You are not authorized to perform this action!');
          }
        }
      }
    }
  });
})(window);
