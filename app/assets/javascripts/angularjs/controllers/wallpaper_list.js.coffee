angular.module('wallgig.controllers')
  .controller 'WallpaperListController', ($scope, $http, $filter) ->
    $scope.toggleFavourite = (wallpaperId) ->
      $http.post("/wallpapers/#{wallpaperId}/toggle_favourite.json")
        .success (data, status, headers, config) ->
          wallpaper = $filter('filter')($scope.wallpapers, {id: data.id})[0]

          if wallpaper
            wallpaper.favourited = data.favourited
            wallpaper.favourites_count = data.favourites_count
