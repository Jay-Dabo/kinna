app.controller('search_account_ctrl', function ($scope) {
    $scope.options = gon.accounting_groups;

	$scope.init = function(account, description) {
        $scope.account = '#'+account;
        $scope.description = '#'+description;
	};

	$scope.select_accounting_group = function() {
        for (x=0; x < gon.accounting_groups.length; x++) {
            if (gon.accounting_groups[x].number == $scope.accounting_group) {
                $scope.accounts = gon.accounting_groups[x].accounts;
                $scope.acc = gon.accounting_groups[x].accounts[0].number;
                $($scope.account).val($scope.accounts[0].id);
                $($scope.description).val($scope.accounts[0].description);
            }
        }
	};
    $scope.select_account = function() {
        for (x=0; x < $scope.accounts.length; x++) {
            if ($scope.accounts[x].number == $scope.acc) {
                $($scope.account).val($scope.accounts[x].id);
                $($scope.description).val($scope.accounts[x].description);
            }
        }
    };
});