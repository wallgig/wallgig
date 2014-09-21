(function (Vue, _, queryString) {
  Vue.component('wallpaper-search', {
    data: {
      isDirty: false,

      // Search defaults
      search: {
        order: 'latest',
        purities: []
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

        console.log('toggling', purity);

        var index = this.search.purities.indexOf(purity);
        if (index === -1) {
          this.search.purities.push(purity);
        } else {
          this.search.purities.$remove(index);
        }
      },

      toggleInclusion: function (collection, index, e) {
        e.preventDefault();
        collection[index].included = ( ! collection[index].included);
      }
    },

    computed: {
      currentOrder: function () {
        return this.orderMappings[this.search.order];
      },

      toQueryString: function () {
        console.log('toQueryString called');
        return queryString.stringify(this.search);
      }
    }
  });
})(Vue, _, queryString);
