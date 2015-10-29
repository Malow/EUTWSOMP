angular.module('EUTWSpecOpsMissionPlanner', ['ngResource', 'ngRoute', 'ngTouch', 'ngAnimate', 'ui.bootstrap'])
  .config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $locationProvider.html5Mode(true)
    $routeProvider
      .when('/',                                {template: (-> JST['dashboard']()), reloadOnSearch: false })
      .when('/login',                           {template: (-> JST['login']()), reloadOnSearch: false })
      .when('/forgot_password',                 {template: (-> JST['forgot_password']()), reloadOnSearch: false })
      .when('/password_reset',                  {template: (-> JST['password_reset']()), reloadOnSearch: false })
      .when('/register',                        {template: (-> JST['register']()),  reloadOnSearch: false })
      .when('/account_settings',                {template: (-> JST['account_settings']()), reloadOnSearch: false })
      .when('/new_mission',                     {template: (-> JST['new_mission']()), reloadOnSearch: false })
      .when('/view_mission/:mission_id',        {template: (-> JST['view_mission']()), reloadOnSearch: false })
      .otherwise({redirectTo: '/'})
  ])
  
  .factory 'Account', ['$resource', ($resource) ->
    $resource("/account")
  ]
  
  .factory 'Role', ['$resource', ($resource) ->
    $resource("/role")
  ]
  
  .factory 'PageData', ['$resource', ($resource) ->
    $resource("/page_data")
  ]
  
  .factory 'Mission', ['$resource', ($resource) ->
    $resource("/mission")
  ]

  .controller 'EUTWSpecOpsMissionPlannerController', ['$scope', '$window', '$location', '$interval', '$routeParams', 'Account', 'Role', 'PageData', 'Mission', 
  ($scope, $window, $location, $interval, $routeParams, Account, Role, PageData, Mission) ->
    
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
    
    if gon.error
      $scope.error = gon.error
    
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
      
    $scope.get_participant_for_mission = (mission_id, user_id) ->
      participants = $scope.get_participants_for_mission(mission_id)
      if participants
        i = 0
        while i < participants.length
          if user_id == participants[i].user_id
            return participants[i]
          ++i
      return null
      
    $scope.get_role_preferences_for_user = (user_id) ->
      role_preferences = []
      if $scope.page_data && $scope.page_data.role_preferences
        i = 0
        while i < $scope.page_data.role_preferences.length
          if user_id == $scope.page_data.role_preferences[i].user_id
            role_preferences.push($scope.page_data.role_preferences[i])
          ++i
      return role_preferences
    
    $scope.get_role_preference_for_user = (user_id, role_id) ->
      role_preferences = $scope.get_role_preferences_for_user(user_id)
      if role_preferences
        i = 0
        while i < role_preferences.length
          if role_id == role_preferences[i].role_id
            return role_preferences[i]
          ++i
      return null
      
    $scope.change_role_preference = (role_id, amount) ->
      $scope.error = null
      role = new Role()
      role.user_action = "change_role_preference"
      role.role_id = role_id
      role.amount = amount
      role.$save ((data, headers) ->
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message

    $scope.create_role = (role_name, role_description) ->
      $scope.error = null
      role = new Role()
      role.user_action = "create_role"
      role.role_name = role_name
      role.role_description = role_description
      role.$save ((data, headers) ->
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.delete_role = (role_id) ->
      $scope.error = null
      role = new Role()
      role.user_action = "delete_role"
      role.role_id = role_id
      role.$save ((data, headers) ->
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
      
    $scope.is_participant_mission_admin = (participant) ->
      user = $scope.get_user(participant.user_id)
      mission = $scope.get_mission(participant.mission_id)
      if participant && mission && user
        if participant.is_mission_admin || mission.creator_id == user.id || user.is_admin
          return true
      return false
          
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
    
    $scope.has_selected_on_dashboard = (selection) ->      
      if $scope.dashboard_selection == selection && $location.path() == '/'
        return true
      return false
    
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
        
    $scope.change_password = (old_password, new_password) ->
      $scope.error = null
      account = new Account()
      account.user_action = "change_password"
      account.old_password = old_password
      account.new_password = new_password
      account.$save ((data, headers) ->
        $location.path("/")
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.forgot_password = (username) ->
      $scope.error = null
      account = new Account()
      account.user_action = "forgot_password"
      account.username = username
      account.$save ((data, headers) ->
        $scope.forgot_password_text = "An email has been sent to you for instructions on how to reset your password."
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.reset_password = (new_password) ->
      $scope.error = null
      account = new Account()
      account.user_action = "reset_password"
      account.new_password = new_password
      account.$save ((data, headers) ->
        $scope.password_reset_text = "Your password has been reset."
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.go_to_login = () ->
      $location.path("/login")
        
    $scope.go_to_register = () ->
      $location.path("/register")
      
    $scope.go_to_forgot_password = () ->
      $location.path("/forgot_password")
      
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
        $scope.refresh()
        $location.path("/login")
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
        
    $scope.make_mission_admin = (participant) ->
      $scope.error = null
      mission = new Mission()
      mission.mission_action = "make_mission_admin"
      mission.user_id = participant.user_id
      mission.mission_id = participant.mission_id
      mission.$save ((data, headers) ->
        $scope.refresh()
      ), (error) ->
        $scope.error = error.data.message
        
    $scope.create_mission = (mission_name, mission_template, mission_datetime) ->
      $scope.error = null
      mission = new Mission()
      mission.mission_action = "create"
      mission.name = mission_name
      mission.template = mission_template
      mission.date = mission_datetime
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
        
        
        
        
        
      
    #DateTime picker
    $scope.mission_datetime = new Date()
    $scope.mission_datetime.setHours(20)
    $scope.mission_datetime.setMinutes(0)
    $scope.minDate = new Date()
    $scope.maxDate = new Date()
    $scope.maxDate.setFullYear($scope.maxDate.getFullYear() + 1)
    
    
    $scope.hstep = 1
    $scope.mstep = 10
    
    
      
    
    
    
    
  ]
  
  
#angular.element($0).scope().am_i_in_mission(4)