app.controller('employee_form_ctrl', function ($scope) {

    $scope.init = function() {
    	var begin = $('#in_begin').val().split(/\D/);
		begin.length == 1 ? $scope.begin_date = new Date() : $scope.begin_date = new Date(begin[0], --begin[1], begin[2]);

		var end = $('#in_end').val().split(/\D/);
		end.length == 1 ? $scope.end_date = new Date() : $scope.end_date = new Date(end[0], --end[1], end[2]);
	};

	$scope.begin_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_begin_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.begin_open = true;
	};

	$scope.end_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_end_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.end_open = true;
	};

});