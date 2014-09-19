(function (Vue, _, bowser, superagent) {
  var config = {
    scrollThrottle: 50,
    infiniteScroll: {
      maxPages: 2,
      distance: 100
    }
  };

  var Pagination = Vue.extend({
    data: {
      hasNextPage: false
    },

    created: function () {
      if ( ! this.$root.settings.infinite_scroll) {
        return;
      }
      console.log(this.hasNextPage);
      this.$watch('hasNextPage', this.hasNextPageDidChange);
      this.$on('nextPageWillLoad', this.nextPageWillLoad);
      this.$on('nextPageDidLoad', this.nextPageDidLoad);
    },

    ready: function () {
      if ( ! this.$root.settings.infinite_scroll) {
        return;
      }

      this.watchScroll();
    },

    beforeDestroy: function () {
      this.unwatchScroll();
    },

    methods: {
      watchScroll: function () {
        window.onscroll = _.throttle(_.bind(this.windowDidScroll, this), config.scrollThrottle);
      },

      unwatchScroll: function () {
        window.onscroll = undefined;
      },

      hasNextPageDidChange: function (value) {
        console.log('hasNextPageDidChange');
        if (value) {
          this.watchScroll();
        } else {
          this.unwatchScroll();
        }
      },

      nextPageWillLoad: function () {
        this.unwatchScroll();
      },

      nextPageDidLoad: function () {
        this.watchScroll();
      },

      windowDidScroll: function () {
        var pageHeight = document.documentElement.scrollHeight;
        var clientHeight = document.documentElement.clientHeight;
        var scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        if (pageHeight - (scrollTop + clientHeight) < config.infiniteScroll.distance) {
          this.$dispatch('infiniteScrollTargetDidReach');
        }
      }
    }
  })

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

      this.$on('infiniteScrollTargetDidReach', this.infiniteScrollTargetDidReach);
    },

    methods: {
      fetchData: function (page) {
        var self = this;

        self.isLoading = true;

        return superagent
          .get(self.endpoint)
          .accept('json')
          .query(location.search.slice(1))
          .query({ page: page })
          .end(function (res) {
            if (res.ok) {
              self.paging = res.body.paging;
              self.wallpapers = res.body.wallpapers;
            }
            self.isLoading = false;
          });
      },

      infiniteScrollTargetDidReach: function () {
        console.log('infiniteScrollTargetDidReach');

        if ( ! this.paging.next) {
          return;
        }

        this.$broadcast('nextPageWillLoad');

        console.log(this.fetchData());
      }
    },

    computed: {
      linkTarget: function () {
        if (this.$root.settings.new_window) {
          return '_blank';
        }
      }
    },

    components: {
      pagination: Pagination
    }
  });
})(Vue, _, bowser, superagent);
