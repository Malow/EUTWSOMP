angular.module('EUTWSpecOpsMissionPlanner', ['ngResource', 'ngRoute', 'ngTouch', 'ngAnimate', 'ui.bootstrap'])
  .config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)
    $routeProvider
      .when('/',                                {template: (-> JST['dashboard']()), reloadOnSearch: false })
      .when('/login',                           {template: (-> JST['login']()), reloadOnSearch: false })
      .when('/register',                        {template: (-> JST['register']()),  reloadOnSearch: false })
      .when('/account_settings',                {template: (-> JST['account_settings']()), reloadOnSearch: false })
      .when('/new_mission',                     {template: (-> JST['new_mission']()), reloadOnSearch: false })
      .when('/view_mission/:mission_id',        {template: (-> JST['view_mission']()), reloadOnSearch: false })
      .otherwise({redirectTo: '/'})
  ])
  
  .factory 'Account', ['$resource', ($resource) ->
    $resource("/account")
  ]
  
  .factory 'PageData', ['$resource', ($resource) ->
    $resource("/page_data")
  ]
  
  .factory 'Mission', ['$resource', ($resource) ->
    $resource("/mission")
  ]

  .controller 'EUTWSpecOpsMissionPlannerController', ['$scope', '$window', '$location', '$interval', '$routeParams', 'Account', 'PageData', 'Mission', 
  ($scope, $window, $location, $interval, $routeParams, Account, PageData, Mission) ->
    
    $scope.refresh = () ->
      page_data = new PageData()
      page_data.$save ((data, headers) ->
        if page_data.table.has_updates
          $scope.page_data = page_data.table
          if $routeParams.mission_id && $scope.page_data
            $scope.set_current_mission_from_page_data($routeParams.mission_id)
      ), (error) ->
        if error.data && error.data.message
          $scope.error = error.data.message
        else
          $scope.error = "No connection to server"

    $scope.intervalPromise = $interval((->
      $scope.refresh()
      return
      ), 1000000)
      
    $scope.refresh()
    
    $scope.get_user = (id) ->
      if $scope.page_data && $scope.page_data.users
        i = 0
        while i < $scope.page_data.users.length
          if $scope.page_data.users[i].id == (Number) id
            return $scope.page_data.users[i]
          ++i
       return null
        
    $scope.get_mission = (id) -> 
      if $scope.page_data && $scope.page_data.missions
        i = 0
        m = null
        while i < $scope.page_data.missions.length
          if $scope.page_data.missions[i].id == (Number) id
            return $scope.page_data.missions[i]
          ++i
      return null
      
    $scope.get_participants_for_mission = (mission_id) ->
      participants = []
      if $scope.page_data && $scope.page_data.participants
        i = 0
        while i < $scope.page_data.participants.length
          if mission_id == $scope.page_data.participants[i].mission_id
            participants.push($scope.page_data.participants[i])
          ++i
      return participants
          
    $scope.set_current_mission_from_page_data = (id) ->
      m = $scope.get_mission(id)
      if m
        $scope.current_mission = new Mission()
        $scope.current_mission.id = m.id
        $scope.current_mission.name = m.name
        $scope.current_mission.date = new Date(m.date)
        $scope.current_mission.created_at = new Date(m.created_at)
        $scope.current_mission.updated_at = new Date(m.updated_at)
        $scope.current_mission.creator = $scope.get_user(m.creator_id)
    
    $scope.$on '$routeChangeSuccess', ->
      if $routeParams.mission_id && $scope.page_data
        $scope.set_current_mission_from_page_data($routeParams.mission_id)
       
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
      
    $scope.go_to_view_mission = (id) ->
      $location.path("/view_mission/" + id)
        
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
      mission = new Mission()
      mission.mission_action = "create"
      mission.name = mission_name
      mission.template = mission_template
      mission.$save ((data, headers) ->
        $location.path("/view_mission/" + mission.id)
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.join_mission = (id) ->
      $scope.error = null
      mission = new Mission()
      mission.mission_action = "join"
      mission.mission_id = id
      mission.$save ((data, headers) ->
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.am_i_in_mission = (mission_id) ->
      if $scope.page_data
        i = 0
        while i < $scope.page_data.participants.length
          if $scope.page_data.participants[i].user_id == $scope.page_data.you.id && mission_id == $scope.page_data.participants[i].mission_id
            return true
          ++i
      return false
        
      
    #DateTime picker
    #$scope.mission_datetime = new Date()
    #$scope.minDate = new Date()
    #$scope.maxDate = $scope.minDate
    #$scope.maxDate.setFullYear($scope.minDate.getFullYear() + 1)
    
    
    
    
    #angular.element($0).scope().am_i_in_mission(4)
    
    $scope.is_date_in_future = (date) ->
      date = new Date(date)
      date.setHours(0)
      date.setMinutes(0)
      date.setSeconds(0)
      date.setMilliseconds(0)
      now = new Date()
      now.setHours(0)
      now.setMinutes(0)
      now.setSeconds(0)
      now.setMilliseconds(0)
      if date >= now
        return true
      return false
    
      
    $scope.force_two_digits = (val) ->
      if val < 10
        return "0#{val}"
      return val
    
    $scope.format_date = (date) ->
      if date
        date = new Date(date)
        year = date.getFullYear()
        month = $scope.force_two_digits(date.getMonth()+1)
        day = $scope.force_two_digits(date.getDate())
        hour = $scope.force_two_digits(date.getHours())
        minute = $scope.force_two_digits(date.getMinutes())
        time_stamp = "" + year + "-" + month + "-" + day + " " + hour + ":" + minute    
        return time_stamp
    
  ]