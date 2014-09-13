/* global _, Vue, superagent */

Vue.component('collection', {
  data: {
    isDraggedOver: false
  },

  methods: {
    onDragEnter: function () {
      if (!this.isInCollection) {
        this.isDraggedOver = true;
      }
    },

    onDragLeave: function () {
      this.isDraggedOver = false;
    }
  }
});
