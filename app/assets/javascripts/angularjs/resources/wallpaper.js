angular.module('wallgig.resources').factory('Wallpaper', function($resource) {
  var Wallpaper = $resource('/wallpapers/:id.json');

  return Wallpaper;
});
