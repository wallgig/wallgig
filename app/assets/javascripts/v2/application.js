//= require bowser
//= require lodash
//= require query-string
//= require superagent
//= require vue
//= require_tree ./components/.
//= require_tree ./directives/.
//= require_self

(function (exports, _, Vue) {
  exports.app = new Vue({
    el: '#wallgig-app',

    data: {
      current_user: null,
      settings: {
        per_page: 20,
        infinite_scroll: false,
        invisible: false,
        new_window: false
      }
    },

    created: function () {
      var self = this;

      // API
      self.$on('apiError', self.handleApiError);
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
})(window, _, Vue);
