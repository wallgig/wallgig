angular.module('wallgig.controllers').controller('WallpaperIndexCtrl', function($scope, Wallpaper) {
  var wallpapers = Wallpaper.query(function() {
    $scope.wallpapers = wallpapers;
  });
});
