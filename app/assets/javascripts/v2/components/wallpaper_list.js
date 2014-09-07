/*global _, Vue, superagent */

Vue.component('wallpaper-list', {
  data: {
    isLoading: true,
    wallpapers: [],
    options: {}
  },

  paramAttributes: ['options'],

  created: function () {
    if (this.options) {
      this.options = JSON.parse(this.options);
    }

    this.fetchData();
  },

  methods: {
    fetchData: function () {
      this.isLoading = true;

      superagent
      .get('/api/v1/wallpapers')
      .query(this.options)
      .end(_.bind(function (res) {
        if (res.ok) {
          this.wallpapers = res.body.data;
        }
        this.isLoading = false;
      }, this));
    },

    toggleFavourite: function (wallpaper, e) {
      e.preventDefault();
      wallpaper.isToggling = true;

      superagent
      .patch('/api/v1/wallpapers/' + wallpaper.id + '/favourite/toggle')
      .end(_.bind(function (res) {
        if (res.ok) {
          _.assign(wallpaper, res.body); // Update favourites_count and favourited
        }
        wallpaper.isToggling = false;
      }, this));
    }
  }
});
