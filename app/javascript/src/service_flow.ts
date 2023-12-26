import jQuery from 'jquery'

export function TabChange(){

  jQuery('.jsTabLabel').on('click', function () {
		jQuery('.jsTabLabel').removeClass('is-active');
		jQuery(this).addClass('is-active');

		jQuery('.jsTabContent').removeClass('is-show');
		const target = jQuery(this).attr('data-target');
    jQuery(target).addClass('is-show');
	});
}


