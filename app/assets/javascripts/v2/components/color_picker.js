//= require jquery
//= require jquery-minicolors

(function (Vue, _, $) {
  Vue.component('color-picker', {
    data: {
      color: null
    },

    ready: function () {
      var self = this;
      var $jQueryEl = $(self.$el);

      if (self.color) {
        $jQueryEl.val(self.color);
      }
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
})(Vue, _, jQuery);
