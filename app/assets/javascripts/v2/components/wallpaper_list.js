/* global _, Vue, superagent, queryString */

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
      this.isLoading = true;

      superagent
      .get(this.endpoint)
      .accept('json')
      .query(queryString.parse(location.search))
      .end(_.bind(function (res) {
        if (res.ok) {
          this.paging = res.body.paging;
          this.wallpapers = res.body.wallpapers;
        }
        this.isLoading = false;
      }, this));
    },

    toggleFavourite: function (wallpaper, e) {
      e.preventDefault();
      wallpaper.isToggling = true;

      superagent
      .patch('/api/v1/wallpapers/' + wallpaper.id + '/favourite/toggle')
      .accept('json')
      .end(_.bind(function (res) {
        if (res.ok) {
          _.assign(wallpaper, res.body); // Update favourites_count and favourited
        } else {
          this.$dispatch('apiError', res);
        }
        wallpaper.isToggling = false;
      }, this));
    },

    onDragStart: function (e) {
      e.dataTransfer.effectAllowed = 'link';
      e.dataTransfer.setData('text/x-wallpaper-id', e.targetVM.id);
      this.$dispatch('wallpaperDragStart', e.targetVM);
    },

    onDragEnd: function (e) {
      this.$dispatch('wallpaperDragEnd');
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
