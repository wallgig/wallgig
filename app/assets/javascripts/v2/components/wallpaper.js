/* global _, Vue, superagent */

Vue.component('wallpaper', {
  data: {
    isToggling: false,
    id: null
  },

  methods: {
    toggleFavourite: function (e) {
      e.preventDefault();

      var self = this;
      if ( ! self.id) {
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
      if ( ! this.$root.current_user) {
        // Not logged in, don't show overlay
        return;
      }

      e.dataTransfer.effectAllowed = 'link';
      e.dataTransfer.setData('text/x-wallpaper-id', this.id);
      this.$root.$broadcast('wallpaperDragStart', this);
    },

    onDragEnd: function () {
      this.$root.$broadcast('wallpaperDragEnd', this);
    }
  }
});
