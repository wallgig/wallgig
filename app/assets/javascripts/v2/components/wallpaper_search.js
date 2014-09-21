(function (Vue, _, queryString) {
  Vue.component('wallpaper-search', {
    data: {
      isDirty: false,

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
      this.$on('wallpaperSearchDidChange', this.wallpaperSearchDidChange);
      this.$on('wallpaperPageWillLoad', this.wallpaperPageWillLoad);
      this.$on('wallpaperPageDidLoad', this.wallpaperPageDidLoad);

      this.$watch('search', this.triggerWallpaperSearch);
      // Watch array in object workaround:
      this.$watch('search.purities', this.triggerWallpaperSearch);
    },

    methods: {
      wallpaperSearchDidChange: function (search) {
        console.log('wallpaperSearchDidChange', search);
        this.$unwatch('search');
        this.$unwatch('search.purities');
        this.search = search;
        this.$watch('search', this.triggerWallpaperSearch);
        this.$watch('search.purities', this.triggerWallpaperSearch);
      },

      triggerWallpaperSearch: function () {
        console.log(arguments);
        this.$unwatch('search');
        this.$unwatch('search.purities');
        this.$dispatch('wallpaperSearchDidChange', this.toQueryStringObject());
        console.log('triggerWallpaperSearch');
      },

      wallpaperPageWillLoad: function () {
        this.$unwatch('search');
        this.$unwatch('search.purities');
      },

      wallpaperPageDidLoad: function () {

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

      toQueryStringObject: function () {
        return _.omit({
          'order': this.search.order,
          'purity[]': this.search.purities,
          'tags[]': _.chain(this.search.facets.tags).where({ included: true }).pluck('id').valueOf(),
          'categories[]': _.chain(this.search.facets.categories).where({ included: true }).pluck('id').valueOf()
        }, _.isEmpty);
      }
    },

    computed: {
      currentOrder: function () {
        return this.orderMappings[this.search.order];
      },

      toQueryString: function () {
        return queryString.stringify(this.toQueryStringObject());
      }
    }
  });
})(Vue, _, queryString);
