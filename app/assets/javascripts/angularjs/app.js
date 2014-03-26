//= require angular
//= require angular-cookies
//= require angular-resource
//= require angular-route

angular.module('wallgig.resources', ['ngResource']);
angular.module('wallgig.services', ['ngResource']);
angular.module('wallgig.directives', []);
angular.module('wallgig.filters', []);
angular.module('wallgig.controllers', ['ngCookies']);
angular.module('wallgig', [
  'wallgig.resources',
  'wallgig.services',
  'wallgig.directives',
  'wallgig.filters',
  'wallgig.controllers',
  'ngRoute'
]);

angular.module('wallgig')
  .config(function($locationProvider) {
    $locationProvider.html5Mode(true);
  });

//= require routes
//= require_tree ./resources
//= require_tree ./services
//= require_tree ./directives
//= require_tree ./filters
//= require_tree ./controllers
