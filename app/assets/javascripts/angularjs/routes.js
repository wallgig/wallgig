angular.module('wallgig').config(function($routeProvider) {
  $routeProvider
    .when('/', { controller: 'WallpaperIndexCtrl', template: JST['angularjs/wallpaper/index'] })
    .when('/wallpapers', { controller: 'WallpaperIndexCtrl', template: JST['angularjs/wallpaper/index'] });
});
