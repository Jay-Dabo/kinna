app.controller('employee_form_ctrl', function ($scope) {

    $scope.init = function() {
    	var begin = $('#in_begin').val().split(/\D/);
		begin.length == 1 ? $scope.begin_date = new Date() : $scope.begin_date = new Date(begin[0], --begin[1], begin[2]);

		var ending = $('#in_ending').val().split(/\D/);
		ending.length == 1 ? $scope.ending_date = new Date() : $scope.ending_date = new Date(ending[0], --ending[1], ending[2]);
	};

	$scope.begin_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_begin_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.begin_open = true;
	};

	$scope.ending_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_ending_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.ending_open = true;
	};

});