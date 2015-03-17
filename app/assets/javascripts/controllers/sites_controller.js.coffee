angular.module("SwiftSearch")
	.controller "SitesController", [ '$scope', '$window', '$http', '$timeout', ($scope, $window, $http, $timeout) ->
		$scope.site =
			url: ''
			error: ''
		$scope.state = 'init'

		reset = () ->
			$scope.site.url = ''
			$scope.state = 'init'
			$scope.siteForm.$setPristine()

		onSuccess = (data, headers) ->
			$scope.state = 'finished'
			$window.location.href = headers().location

		validate = (url) ->
			
		onError = (data) ->
			$scope.state = 'error'
			$scope.site.error = data.message
			$timeout(reset, 3000)

		$scope.createSite = () ->
			$scope.state = 'processing'
			$http({
				url: '/sites'
				method: 'POST'
				data: $scope.site
				})
				.success (data, status, headers, config) ->
					onSuccess(data, headers)
				.error (data, status, headers, config) ->
					onError(data)

	]
