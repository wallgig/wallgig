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
      },

      myObj: {
        myArr: []
      },
      myArr: []
    },

    created: function () {
      console.log('wallpaper search component ready');

      this.$on('wallpaperSearchDidChange', function () {
        console.log('wallpaperSearchDidChange created');
      });
      this.$watch('search.purities', function () {
        console.log(arguments);
      });
    },

    ready: function () {
      this.$on('wallpaperSearchDidChange', function () {
        console.log('wallpaperSearchDidChange ready');
      });
    },

    methods: {
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
