//= require bowser
//= require lodash
//= require query-string
//= require superagent
//= require vue
//= require_tree ./components/.
//= require_tree ./directives/.
//= require_self

(function (exports, WG, _) {
  exports.app = new WG({
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
      this.$on('apiError', this.apiDidError);
    },

    methods: {
      apiDidError: function (res) {
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
})(window, Vue, _);
