//= require jquery
//= require jquery-minicolors

/* global Vue, _, jQuery */

Vue.component('color-picker', {
  data: {
    color: null
  },

  ready: function () {
    var self = this;
    var $jQueryEl = jQuery(self.$el);

    $jQueryEl.val(self.color);
    $jQueryEl.minicolors({
      change: function (hex) {
        self.color = hex.slice(1);
      },
      theme: 'bootstrap'
    });

    self.$watch('color', function (value) {
      $jQueryEl.minicolors('value', value);
    });
  }
});
