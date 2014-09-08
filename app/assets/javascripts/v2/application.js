//= require lodash
//= require query-string
//= require vue
//= require superagent
//= require ./components/wallpaper_list

//= require_self

/* global _, Vue, superagent */

(function (exports) {
  exports.app = new Vue({
    el: '#wallgig-app',

    created: function () {
      this.$on('unauthorized', this.showUnauthorizedMessage);
    },

    methods: {
      showUnauthorizedMessage: function (message) {
        // TODO use modal box
        if (message) {
          alert(message);
        } else {
          alert('You are not authorized to perform this action!');
        }
      }
    }
  });
})(window);
