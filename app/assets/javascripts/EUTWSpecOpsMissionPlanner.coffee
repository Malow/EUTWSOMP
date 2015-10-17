angular.module('EUTWSpecOpsMissionPlanner', ['ngResource', 'ngRoute', 'ngTouch', 'ngAnimate', 'ui.bootstrap'])
  .config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)
    $routeProvider
      .when('/',                                {template: (-> JST['dashboard']()),  reloadOnSearch: false })
      .when('/login',                           {template: (-> JST['login']()),  reloadOnSearch: false })
      .when('/register',                        {template: (-> JST['register']()),  reloadOnSearch: false })
      .when('/account_settings',                {template: (-> JST['account_settings']()),  reloadOnSearch: false })
      .when('/new_mission',                     {template: (-> JST['new_mission']()),  reloadOnSearch: false })
      .otherwise({redirectTo: '/'})
  ])
  
  .factory 'Account', ['$resource', ($resource) ->
    $resource("/account")
  ]
  
  .factory 'PageData', ['$resource', ($resource) ->
    $resource("/page_data")
  ]

  .controller 'EUTWSpecOpsMissionPlannerController', ['$scope', '$window', '$location', '$interval', 'Account', 'PageData', ($scope, $window, $location, $interval, Account, PageData) ->
    
    $scope.refresh = () ->
      page_data = new PageData()
      page_data.$save ((data, headers) ->
        if page_data.table.has_updates
          $scope.page_data = page_data.table
      ), (error) ->
        if error.data && error.data.message
          $scope.error = error.data.message
        else
          $scope.error = "No connection to server"

    $scope.intervalPromise = $interval((->
      $scope.refresh()
      return
      ), 100000)
      
    $scope.refresh()
       
    $scope.dashboard_selection = 'missions'
    
                
    $scope.register = (username, password, email) ->
      $scope.error = null
      account = new Account()
      account.user_action = "register"
      account.username = username
      account.password = password
      account.email = email
      account.$save ((data, headers) ->
        $location.path("/")
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.login = (username, password) ->
      $scope.error = null
      account = new Account()
      account.user_action = "log_in"
      account.username = username
      account.password = password
      account.$save ((data, headers) ->
        $location.path("/")
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.go_to_register = () ->
      $location.path("/register")
      
    $scope.go_to_account_settings = () ->
      $location.path("/account_settings")
      
    $scope.go_to_dashboard = (db_selection) ->
      $location.path("/")
      $scope.dashboard_selection = db_selection
      
    $scope.go_to_new_mission = () ->
      $location.path("/new_mission")
        
    $scope.logout = () ->
      $scope.error = null
      account = new Account()
      account.user_action = "log_out"
      account.$save ((data, headers) ->
        $location.path("/login")
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.make_admin = (user) ->
      $scope.error = null
      account = new Account()
      account.user_action = "make_admin"
      account.user = user
      account.$save ((data, headers) ->
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.create_mission = (mission_name, mission_template, mission_datetime) ->
      $scope.error = null
      console.log("Creating mission: " + mission_name)
      console.log("Template: " + mission_template)
      console.log("Datetime: " + mission_datetime)
      
      
      
      
    #DateTime picker
    #$scope.mission_datetime = new Date()
    #$scope.minDate = new Date()
    #$scope.maxDate = $scope.minDate
    #$scope.maxDate.setFullYear($scope.minDate.getFullYear() + 1)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    $scope.today = ->
      $scope.dt = new Date
      return

    $scope.today()

    $scope.clear = ->
      $scope.dt = null
      return

    # Disable weekend selection

    $scope.disabled = (date, mode) ->
      mode == 'day' and (date.getDay() == 0 or date.getDay() == 6)

    $scope.toggleMin = ->
      $scope.minDate = if $scope.minDate then null else new Date
      return

    $scope.toggleMin()
    $scope.maxDate = new Date(2020, 5, 22)

    $scope.open = ($event) ->
      $scope.status.opened = true
      return

    $scope.setDate = (year, month, day) ->
      $scope.dt = new Date(year, month, day)
      return

    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
    $scope.formats = [
      'dd-MMMM-yyyy'
      'yyyy/MM/dd'
      'dd.MM.yyyy'
      'shortDate'
    ]
    $scope.format = $scope.formats[0]
    $scope.status = opened: false
    tomorrow = new Date
    tomorrow.setDate tomorrow.getDate() + 1
    afterTomorrow = new Date
    afterTomorrow.setDate tomorrow.getDate() + 2
    $scope.events = [
      {
        date: tomorrow
        status: 'full'
      }
      {
        date: afterTomorrow
        status: 'partially'
      }
    ]

    $scope.getDayClass = (date, mode) ->
      if mode == 'day'
        dayToCheck = new Date(date).setHours(0, 0, 0, 0)
        i = 0
        while i < $scope.events.length
          currentDay = new Date($scope.events[i].date).setHours(0, 0, 0, 0)
          if dayToCheck == currentDay
            return $scope.events[i].status
          i++
      ''    
    
    

  ]