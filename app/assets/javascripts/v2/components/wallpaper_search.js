(function (Vue, _, queryString) {
  Vue.component('wallpaper-search', {
    data: {
      isDirty: false,
      isSearching: false,

      // Search defaults
      search: {
        order: 'latest',
        purities: [],
        facets: {
          categories: [],
          tags: []
        }
      },

      // Mappings
      purityMappings: {
        sfw: 'SFW',
        sketchy: 'Sketchy',
        nsfw: 'NSFW'
      },
      orderMappings: {
        latest: 'Recency',
        score: 'Relevance',
        popular: 'Popularity',
        random: 'Random'
      }
    },

    created: function () {
      this.$on('wallpaperPageWillLoad', this.wallpaperPageWillLoad);
      this.$on('wallpaperPageDidLoad', this.wallpaperPageDidLoad);
    },

    methods: {
      wallpaperPageWillLoad: function () {
        this.isSearching = true;
      },

      wallpaperPageDidLoad: function (wallpaperPage) {
        this.search = wallpaperPage.search;
        this.isSearching = false;
      },

      togglePurity: function (purity, e) {
        e.preventDefault();

        var index = this.search.purities.indexOf(purity);
        if (index === -1) {
          this.search.purities.push(purity);
        } else {
          if (this.search.purities.length > 1) {
            // Must select at least one purity
            this.search.purities.$remove(index);
          }
        }
      },

      toggleInclusion: function (collection, index, e) {
        e.preventDefault();
        collection[index].included = ( ! collection[index].included);
      },

      searchButtonDidClick: function () {
        this.$dispatch('searchDidRequest', this.toQueryStringObject());
      },

      toQueryStringObject: function () {
        var search = _.cloneDeep(this.search);
        return _.omit({
          'q': search.q,
          'order': search.order,
          'color': search.color,
          'purity[]': search.purities,
          'tags[]': _.chain(search.facets.tags).where({ included: true }).pluck('id').valueOf(),
          'categories[]': _.chain(search.facets.categories).where({ included: true }).pluck('id').valueOf()
        }, _.isEmpty);
      }
    },

    computed: {
      currentOrder: function () {
        return this.orderMappings[this.search.order];
      }
    }
  });
})(Vue, _, queryString);
