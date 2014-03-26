angular.module('wallgig.controllers').controller('MainCtrl', function($scope, $rootScope, $window) {
  $rootScope.$on('$routeChangeSuccess', function(event, next, current) {
    if (angular.isUndefined(next)) {
      $location.path($location.path()).replace();
    }
  });
});
