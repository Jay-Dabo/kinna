app.controller('ModalCtrl', function ($scope, $modal, $log) {

	$scope.items = ['item1', 'item2', 'item3'];
	$scope.date = new Date();

	$scope.open = function ($event, size, el) {
		//$scope.date = new Date();
		var elem = '#'+el;
		var temp = $(elem).html();

		var modalInstance = $modal.open({
			template: temp,
			controller: 'ModalInstanceCtrl',
			size: size,
			resolve: {
				dat: function () {
					return $scope.date;
				}
			}
		});

		modalInstance.result.then(function (selectedItem) {
			$scope.selected = selectedItem;
		}, function () {
			$log.info('Modal dismissed at: ' + new Date());
		});
		$event.preventDefault();
		$event.stopPropagation();
	};
	$scope.open_delete = function ($event, size, el, o) {
		$scope.obj = o;
		var elem = '#'+el;
		var temp = $(elem).html();
		var modalInstance = $modal.open({
			template: temp,
			controller: 'ModalDeleteInstanceCtrl',
			size: size,
			resolve: {
				obj: function () {
					return $scope.obj;
				}
			}
		});

		modalInstance.result.then(function (selectedItem) {
			$scope.selected = selectedItem;
		}, function () {
			$log.info('Modal dismissed at: ' + new Date());
		});
		$event.preventDefault();
		$event.stopPropagation();
	};

});


app.controller('ModalInstanceCtrl', function ($scope, $modalInstance, dat) {
	$scope.date = dat;
	$scope.dpOptions = {'starting-day': 1,'show-weeks': false};
	$scope.openDate = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.isOpen = true;
	};


	$scope.ok = function ($event) {
		$event.preventDefault();
		$event.stopPropagation();
	};

	$scope.cancel = function () {
		$modalInstance.dismiss('cancel');
	};
});
app.controller('ModalDeleteInstanceCtrl', function ($scope, $modalInstance, obj) {
	$scope.obj = obj;
	$scope.ok = function ($event) {
		$event.preventDefault();
		$event.stopPropagation();
	};

	$scope.cancel = function () {
		$modalInstance.dismiss('cancel');
	};
});

app.controller('ModalMessageInstanceCtrl', function ($scope, $modalInstance, msg) {
	$scope.message = msg;
	$scope.openDate = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.isOpen = true;
	};

	$scope.cancel = function () {
		$modalInstance.dismiss('cancel');
	};
});