/* global _, Vue, superagent */

Vue.component('wallpaper-list', {
  data: {
    isLoading: true,
    isFirst: false,

    paging: {},
    wallpapers: [],

    options: {}
  },

  paramAttributes: [
    'data',
    'endpoint',
    'options'
  ],

  created: function () {
    if (this.options) {
      this.options = JSON.parse(this.options);
    }

    if ( ! this.endpoint) {
      this.endpoint = '/api/v1/wallpapers';
    }

    if (this.data) {
      this.data = JSON.parse(this.data);
      this.wallpapers = this.data.wallpapers;
      this.paging = this.data.paging;
      this.isLoading = false;
      this.isFirst = true;
    } else {
      this.fetchData();
    }
  },

  methods: {
    fetchData: function () {
      var self = this;

      self.isLoading = true;

      superagent
        .get(this.endpoint)
        .accept('json')
        .query(location.search.slice(1))
        .end(function (res) {
          if (res.ok) {
            self.paging = res.body.paging;
            self.wallpapers = res.body.wallpapers;
          }
          self.isLoading = false;
        });
    }
  },

  computed: {
    linkTarget: function () {
      if (this.$root.settings.new_window) {
        return '_blank';
      }
    }
  }
});
