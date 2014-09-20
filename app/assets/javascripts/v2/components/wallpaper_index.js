(function (Vue, _, superagent, queryString) {
  var config = {
    scrollThrottle: 50,
    infiniteScroll: {
      maxPages: null, // Computed value: floor(maxImages / settings.perPage)
      maxImages: 300,
      distance: 100
    }
  };

  var Pagination = Vue.extend({
    created: function () {
      if ( ! this.$root.settings.infinite_scroll) {
        return;
      }
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
      isLoading: false,
      search: {},
      wallpaperPages: [],
      options: {},
      previousPage: null,
      nextPage: null
    },

    paramAttributes: [
      'data',
      'endpoint',
      'options'
    ],

    created: function () {
      config.infiniteScroll.maxPages = Math.floor(config.infiniteScroll.maxImages / this.$root.settings.per_page);

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
        this.fetchPage();
      }

      this.$on('infiniteScrollTargetDidReach', this.infiniteScrollTargetDidReach);
    },

    methods: {
      fetchPage: function (page) {
        this.$broadcast('wallpaperPageWillLoad');
        this.isLoading = true;

        superagent
          .get(this.endpoint)
          .accept('json')
          .query(location.search.slice(1))
          .query({ page: page || 1 })
          .end(_.bind(function (res) {
            if (res.ok) {
              this.wallpaperPageDidLoad(res.body);
            }
            this.isLoading = false;
          }, this));
      },

      wallpaperPageDidLoad: function (wallpaperPage) {
        // Set previous page number
        if (this.wallpaperPages.length === 0) {
          if (wallpaperPage.paging.previous) {
            this.previousPage = wallpaperPage.paging.current_page - 1;
          }
        }

        // Set next page number
        if (wallpaperPage.paging.next) {
          this.nextPage = wallpaperPage.paging.current_page + 1;
        } else {
          this.nextPage = null;
        }

        this.search = wallpaperPage.search; // Refresh search
        this.wallpaperPages.push(_.pick(wallpaperPage, 'paging', 'wallpapers'));

        this.$broadcast('wallpaperPageDidLoad');
      },

      infiniteScrollTargetDidReach: function () {
        if (this.wallpaperPages.length < config.infiniteScroll.maxPages
            && this.nextPage
          ) {
          // Fetch next page
          this.fetchPage(this.nextPage);
        }
      },

      generatePageHref: function (page) {
        var query = queryString.parse(window.location.search);
        query.page = page;
        return window.location.pathname + '?' + queryString.stringify(query);
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
})(Vue, _, superagent, queryString);
