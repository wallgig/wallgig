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

    paramAttributes: ['settings'],

    created: function () {
      if (this.settings) {
        this.settings = JSON.parse(this.settings);
      }

      this.$on('apiError', this.handleApiError);
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
