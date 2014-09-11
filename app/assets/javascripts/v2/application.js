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
      var self = this;

      if (self.settings) {
        self.settings = JSON.parse(self.settings);
      }

      // API
      self.$on('apiError', self.handleApiError);

      // Wallpaper
      self.$on('wallpaperDragStart', function (wallpaper) {
        self.$broadcast('requestShowCollectionOverlay', { wallpaper: wallpaper });
      });
      self.$on('wallpaperDragEnd', function () {
        self.$broadcast('requestHideCollectionOverlay');
      });
    },

    methods: {
      handleApiError: function (res) {
        if (res.unauthorized) {
          if (res.body && res.body.message) {
            alert(res.body.message);
          } else {
            alert('You are not authorized to perform this action!');
          }
        } else {
          alert(res.toError());
        }
      }
    }
  });
})(window);
