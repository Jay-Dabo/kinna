app.controller('verificate_form_ctrl', function ($scope) {

    $scope.posting_options = {'starting-day': 1,'show-weeks': false};

    $scope.open_posting_date = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.posting_open = true;
    };

    $scope.init = function() {
        var min_date = gon.root.accounting_period.allow_from;
        var max_date = gon.root.accounting_period.allow_to;
        $scope.params = set_date(min_date, max_date);

        $scope.description = $('#verificate_description').val();
        $scope.period = gon.root.accounting_period.id;
		var posting = $('#in_posting').val().split(/\D/);
		posting.length == 1 ? $scope.posting_date = min_date : $scope.posting_date = new Date(posting[0], --posting[1], posting[2]);

	};

    function set_date(min, max) {
        $scope.min_date = min;
        $scope.max_date = max;
        $scope.posting_date = min;
    }
});