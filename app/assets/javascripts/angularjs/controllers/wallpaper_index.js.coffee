angular.module('wallgig.controllers')
  .controller 'WallpaperIndexController', ($scope, Wallpaper) ->
    # wallpapers = Wallpaper.query ->
    #   $scope.$apply ->
    #     $scope.wallpapers = wallpapers
