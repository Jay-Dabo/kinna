app.controller('tax_return_form_ctrl', function ($scope) {

    $scope.init = function() {
        var deadline = $('#in_deadline').val().split(/\D/);
        deadline.length == 1 ? $scope.deadline_date = new Date() : $scope.deadline_date = new Date(deadline[0], --deadline[1], deadline[2]);
	};

    $scope.deadline_options = {'starting-day': 1,'show-weeks': false};
    $scope.open_deadline_date = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.deadline_open = true;
    };
});