app.controller('verificate_item_form_ctrl', function ($scope) {
    $scope.options = gon.accounting_groups;

	$scope.init = function() {
	};

	$scope.select_accounting_group = function() {
        for (x=0; x < gon.accounting_groups.length; x++) {
            if (gon.accounting_groups[x].number == $scope.accounting_group) {
                $scope.accounts = gon.accounting_groups[x].accounts;
                $scope.acc = gon.accounting_groups[x].accounts[0].number;
                $('#verificate_item_account').val($scope.accounts[0].number);
                $('#verificate_item_description').val($scope.accounts[0].name);
            }
        }
	};
    $scope.select_account = function() {
        for (x=0; x < $scope.accounts.length; x++) {
            if ($scope.accounts[x].number == $scope.acc) {
                $('#verificate_item_account').val($scope.accounts[x].number);
                $('#verificate_item_description').val($scope.accounts[x].name);
            }
        }
    };
});