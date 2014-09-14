//= require jquery
//= require jquery-minicolors

/* global Vue, _, jQuery */

Vue.component('color-picker', {
  data: {
    color: null
  },

  ready: function () {
    jQuery(this.$el).minicolors({
      change: _.bind(this.onChange, this),
      defaultValue: this.color,
      theme: 'bootstrap'
    });
  },

  methods: {
    onChange: function (hex) {
      this.color = hex.slice(1); // Removes '#'
    }
  }
});
