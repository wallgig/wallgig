(function (Vue, _) {
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
        latest: 'by recency',
        score: 'by relevance',
        popular: 'by popularity',
        random: 'by random'
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
      changeOrder: function (order, e) {
        e.preventDefault();
        this.search.order = order;
      },

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

      toggleTagInclusion: function (index, e) {
        e.preventDefault();

        this.search.facets.tags[index].included = !this.search.facets.tags[index].included;
      }
    },

    computed: {
      currentOrder: function () {
        return this.orderMappings[this.search.order];
      },

      toQueryString: function () {
        console.log('toQueryString called');
        return 'ok';
      }
    }
  });
})(Vue, _);
