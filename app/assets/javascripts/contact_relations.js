app.controller('contact_relations_form_ctrl', function ($scope) {
	$scope.contacts = [];
	$scope.selected = undefined;
	$scope.add = true;

	$scope.init = function() {
		if (typeof $('#search')[0] != 'undefined') {
			$scope.contacts = gon.contacts;	
		}

		$scope.add = true;
		//$scope.selected = $('#contact_email').val();
	};
	$scope.type_ahead_contact = function (item, model, label) {
	    $('#contact_id').val(item.id);
	    for (var i = 0; i < $scope.contacts.length; i++) {
	    	if ($scope.contacts[i].id == item.id) {
	    		$('#contact_email').val($scope.contacts[i].email);
	    		$('#contact_name').val($scope.contacts[i].name);
	    		$('#contact_telephone').val($scope.contacts[i].telephone);
	    		$('#contact_address').val($scope.contacts[i].address);
	    		$('#contact_zip').val($scope.contacts[i].zip);
	    		$('#contact_country').val($scope.contacts[i].country);
	    		$('#contact_comment').val($scope.contacts[i].comment);
	    		$scope.add = false;
	    	}
	    }
	};
	$scope.new_contact = function ($event) {
		//$('#contact_id').val(0);
		//$event.preventDefault();
	    //$event.stopPropagation();
	}
});
