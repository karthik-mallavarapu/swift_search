angular.module("SwiftSearch")
  .controller "SearchController", [ '$scope', '$window', '$http', '$timeout', '$sce', ($scope, $window, $http, $timeout, $sce) ->

    $scope.state = 'init'
    $scope.pages = []

    $scope.to_trusted = (html_code) ->
      $sce.trustAsHtml(html_code)

    searchSuccess = (data) ->
      $scope.pages = data.search
      if $scope.pages.length == 0
        showFlashMsg("No results found!!", "success")
      $scope.state = 'complete'

    searchError = (data) ->
      showFlashMsg(data.message, "danger")
      $scope.state = 'complete'
      $timeout($scope.resetForm, 3000)

    $scope.resetForm = () ->
      $scope.state = 'init'
      $scope.search_term = ''
      $scope.searchForm.$setPristine()

    showFlashMsg = (msg, type) ->
      $("#flash_messages").html('<div class="alert alert-'+type+' fade in"><button class="close" data-dismiss="alert">×</button>'+msg+'</div>');

    getSiteID = () ->
      return angular.element('#search_div').data("site")

    $scope.reloadSite = () ->
      $scope.state = "processing"
      site =
        id: getSiteID()
      $http({
        url: '/reload'
        data: site
        method: 'POST'
      })
      .success (data, status, headers, config) ->
        showFlashMsg(data.message, "success")
        $scope.resetForm()
      .error (data, status, headers, config) ->
        showFlashMsg(data.message, "danger")
        $scope.resetForm()

    $scope.searchSite = () ->
      $scope.state = "processing"
      site = getSiteID()
      $http({
        url: '/search?search_term='+$scope.search_term+'&site_id='+site
        method: 'GET'
        headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" }
      })
      .success (data, status, headers, config) ->
        searchSuccess(data)
      .error (data, status, headers, config) ->
        searchError(data)



  ]
