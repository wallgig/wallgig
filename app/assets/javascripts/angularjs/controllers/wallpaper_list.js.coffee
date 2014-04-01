angular.module('wallgig.controllers')
  .controller 'WallpaperListController', ($scope) ->
    $scope.toggleFavourite = (wallpaperId) ->
      alert(wallpaperId)
