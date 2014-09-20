(function (Vue, _, superagent) {
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
      this.$on('wallpaperPageWillLoad', this.wallpaperPageWillLoad);
      this.$on('wallpaperPageDidLoad', this.wallpaperPageDidLoad);
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
        if (value) {
          this.watchScroll();
        } else {
          this.unwatchScroll();
        }
      },

      wallpaperPageWillLoad: function () {
        this.unwatchScroll();
      },

      wallpaperPageDidLoad: function () {
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
  });

  var WallpaperList = Vue.extend({
    created: function () {
      console.log('Wallpaper list created');
    }
  });

  Vue.component('wallpaper-index', {
    data: {
      isLoading: true,
      wallpaperPages: [],
      options: {},
      currentPaging: null
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
        // Process preloaded data
        this.wallpaperPageDidLoad(JSON.parse(this.data));
        this.data = undefined;
      } else {
        this.fetchData();
      }

      this.$on('infiniteScrollTargetDidReach', this.infiniteScrollTargetDidReach);
    },

    methods: {
      fetchData: function (page) {
        this.$broadcast('wallpaperPageWillLoad');
        this.isLoading = true;

        superagent
          .get(this.endpoint)
          .accept('json')
          .query(location.search.slice(1))
          .query({ page: page })
          .end(_.bind(function (res) {
            if (res.ok) {
              this.wallpaperPageDidLoad(res.body);
            }
            this.isLoading = false;
          }, this));
      },

      wallpaperPageDidLoad: function (wallpaperPage) {
        this.wallpaperPages.push(wallpaperPage);
        this.currentPaging = wallpaperPage.paging;
        this.$broadcast('wallpaperPageDidLoad');
      },

      infiniteScrollTargetDidReach: function () {
        if (this.wallpaperPages.length < config.infiniteScroll.maxPages
            && this.currentPaging
            && this.currentPaging.current_page < this.currentPaging.total_pages
          ) {
          // Fetch next page
          // TODO use this.currentPaging.next as endpoint
          this.fetchData(this.currentPaging.current_page + 1);
        }
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
      pagination: Pagination,
      'wallpaper-list': WallpaperList
    }
  });
})(Vue, _, superagent);
