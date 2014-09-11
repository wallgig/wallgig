/* global _, Vue, superagent */

Vue.component('wallpaper', {
  data: {
    isToggling: false
  },

  methods: {
    toggleFavourite: function (e) {
      var self = this;

      e.preventDefault();

      if ( !self.id) {
        return;
      }

      self.isToggling = true;

      superagent
        .patch('/api/v1/wallpapers/' + self.id + '/favourite/toggle.json')
        .end(function (res) {
          if (res.ok) {
            _.assign(self.$data, res.body); // Update favourites_count and favourited
          } else {
            self.$dispatch('apiError', res);
          }
          self.isToggling = false;
        });
    },

    onDragStart: function (e) {
      e.dataTransfer.effectAllowed = 'link';
      e.dataTransfer.setData('text/x-wallpaper-id', this.id);
      this.$dispatch('wallpaperDragStart', this);
    },

    onDragEnd: function (e) {
      this.$dispatch('wallpaperDragEnd', this);
    }
  }
});
