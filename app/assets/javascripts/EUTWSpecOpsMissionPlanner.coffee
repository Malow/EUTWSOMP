angular.module('EUTWSpecOpsMissionPlanner', ['ngResource', 'ngRoute', 'ngTouch'])
  .config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)
    $routeProvider
      .when('/',                                {template: (-> JST['dashboard']()),  reloadOnSearch: false })
      .when('/login',                           {template: (-> JST['login']()),  reloadOnSearch: false })
      .when('/register',                        {template: (-> JST['register']()),  reloadOnSearch: false })
      .when('/account_settings',                {template: (-> JST['account_settings']()),  reloadOnSearch: false })
      .otherwise({redirectTo: '/'})
  ])
  
  .factory 'Authentication', ['$resource', ($resource) ->
    $resource("/authentication")
  ]

  .controller 'EUTWSpecOpsMissionPlannerController', ['$scope', '$window', '$location', 'Authentication', ($scope, $window, $location, Authentication) ->
    
    if gon.error
      $scope.error = gon.error
    
    if gon.your_username
      $scope.your_username = gon.your_username
        
    $scope.register = (username, password, email) ->
      $scope.error = null
      authentication = new Authentication()
      authentication.user_action = "register"
      authentication.username = username
      authentication.password = password
      authentication.email = email
      authentication.$save ((data, headers) ->
        $scope.your_username = username
        $location.path("/")
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.login = (username, password) ->
      $scope.error = null
      authentication = new Authentication()
      authentication.user_action = "log_in"
      authentication.username = username
      authentication.password = password
      authentication.$save ((data, headers) ->
        $scope.your_username = username
        $location.path("/")
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.go_to_register = () ->
      $location.path("/register")
      
    $scope.go_to_account_settings = () ->
      $location.path("/account_settings")
        
    $scope.logout = () ->
      $scope.error = null
      authentication = new Authentication()
      authentication.user_action = "log_out"
      authentication.$save ((data, headers) ->
        $location.path("/login")
      ), (error) ->
        $scope.error = error.data.message
        
  ]