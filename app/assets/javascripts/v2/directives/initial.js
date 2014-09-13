/* global Vue, _ */

Vue.directive('initial', {
  isLiteral: true,

  bind: function () {
    var data = JSON.parse(this.expression);
    _.assign(this.vm.$data, data);
  }
});
