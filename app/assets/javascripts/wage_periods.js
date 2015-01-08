app.controller('wage_period_form_ctrl', function ($scope) {

    $scope.init = function() {
    	var from = $('#in_from').val().split(/\D/);
		from.length == 1 ? $scope.from_date = new Date() : $scope.from_date = new Date(from[0], --from[1], from[2]);

		var to = $('#in_to').val().split(/\D/);
		to.length == 1 ? $scope.to_date = new Date() : $scope.to_date = new Date(to[0], --to[1], to[2]);

        var payment = $('#in_payment').val().split(/\D/);
        payment.length == 1 ? $scope.payment_date = new Date() : $scope.payment_date = new Date(payment[0], --payment[1], payment[2]);

        var deadline = $('#in_deadline').val().split(/\D/);
        deadline.length == 1 ? $scope.deadline_date = new Date() : $scope.deadline_date = new Date(deadline[0], --deadline[1], deadline[2]);
	};

	$scope.from_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_from_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.from_open = true;
	};

	$scope.to_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_to_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.to_open = true;
	};


    $scope.payment_options = {'starting-day': 1,'show-weeks': false};
    $scope.open_payment_date = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.payment_open = true;
    };

    $scope.deadline_options = {'starting-day': 1,'show-weeks': false};
    $scope.open_deadline_date = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.deadline_open = true;
    };
});