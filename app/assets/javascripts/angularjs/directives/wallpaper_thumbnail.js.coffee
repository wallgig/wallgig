angular.module('wallgig.directives')
  .directive 'wgWallpaperThumbnail', ->
    restrict: 'A'
    replace: true
    template: '<img
      ng-src="{{wallpaper.thumbnail_image_url}}"
      width="{{wallpaper.thumbnail_image_width}}"
      height="{{wallpaper.thumbnail_image_height}}"
      class="img-wallpaper">'
