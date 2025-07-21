// This is a client side javascript file

$j = jQuery.noConflict();

jQuery(document.documentElement).on('change', '.checkAllContainer .checkAllHeader', function() {
	jQuery(this).closest('.checkAllContainer').find('.checkAllRow').prop('checked', this.checked);
 });

jQuery(document.documentElement).on('change', '.checkAllContainer .checkAllRow', function() {
	var l = jQuery(this).closest('.checkAllContainer').find('.checkAllRow').filter(':not(:checked)').length;
	jQuery(this).closest('.checkAllContainer').find('.checkAllHeader').prop('checked', l == 0);	
});

/*
$j(function(){
 	$j('.checkAllContainer .checkAllHeader').change(function() {
 		$j(this).closest('.checkAllContainer').find('.checkAllRow').prop('checked', this.checked);	
 	});
 	
 	$j('.checkAllContainer .checkAllRow').change(function() {
 		var l = $j(this).closest('.checkAllContainer').find('.checkAllRow').filter(':not(:checked)').length;
 		$j(this).closest('.checkAllContainer').find('.checkAllHeader').prop('checked', l == 0);	
 	});
});
*/

window.dhc = {
	validateMasterCheckboxes: function(masterCssClass) {
		console.log('Validating master checkboxes...' + masterCssClass);
		// Select all the master checkboxes.
		var messages = [];
		$j('input[type=checkbox].dhc-master-checkbox').each(function(i, e) {
			e = $j(e);
			if (!e.prop('checked') && $j(e.data('master-for')).length) {
				// if the master is not checked, and there are controls matching with master-for
				// selector, consider this check has failed.
				messages.push(e.data('master-message'));
			}
		});
		if (messages && messages.length) {
			// if there are messages to be shown, that means the validation fails.
			alert(messages.join('\n\n'));
			return false;
		}
	}
}