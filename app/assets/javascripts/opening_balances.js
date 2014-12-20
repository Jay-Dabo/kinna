app.controller('opening_balance_form_ctrl', function ($scope) {

    $scope.posting_options = {'starting-day': 1,'show-weeks': false};

    $scope.open_posting_date = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.posting_open = true;
    };

    $scope.init = function() {

        var min_date = gon.accounting_periods[0].allow_from;
        var max_date = gon.accounting_periods[0].allow_to;
        set_date(min_date, max_date);

        $scope.period = gon.accounting_periods[0].id;
		var posting = $('#in_posting').val().split(/\D/);
		posting.length == 1 ? $scope.posting_date = min_date : $scope.posting_date = new Date(posting[0], --posting[1], posting[2]);

	};

    $scope.change_period = function() {
        for (x=0; x<gon.accounting_periods.length; x++) {
            if ($scope.period == gon.accounting_periods[x].id) {
                min_date = gon.accounting_periods[x].allow_from;
                max_date = gon.accounting_periods[x].allow_to;
                set_date(min_date, max_date);
            }
        }
    };

    function set_date(min, max) {
        $scope.min_date = min;
        $scope.max_date = max;
        $scope.posting_date = min;
    }
});