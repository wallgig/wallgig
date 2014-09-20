(function (Vue, _) {
  Vue.component('wallpaper-search', {
    data: {
      isDirty: false,

      // Search defaults
      search: {
        order: 'latest',
        purity: ['sfw']
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
      }
    },

    created: function () {
      console.log('wallpaper search component ready');
      console.log(this.orderMappings);
    },

    ready: function () {
      console.log(this.search);
      console.log(this.orderMappings);
    },

    methods: {
      changeOrder: function (order, e) {
        e.preventDefault();
        this.search.order = order;
      },

      togglePurity: function (purity, e) {
        e.preventDefault();
        console.log('toggling', purity);
        console.log(this.search);
        this.search.purity.push(purity);
        console.log(this.search);
        if (_.contains(this.search.purity, purity)) {
          this.search.purity = _.without(this.search.purity, purity);
        } else {
          this.search.purity.push(purity);
        }
      }
    },

    computed: {
      currentOrder: function () {
        return this.orderMappings[this.search.order];
      }
    }
  });
})(Vue, _);
