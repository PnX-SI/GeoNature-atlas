define(['jquery', './tooltip'], function($, Tooltip) {
	'use strict';

	$ = 'default' in $ ? $['default'] : $;
	Tooltip = 'default' in Tooltip ? Tooltip['default'] : Tooltip;

	var pluginName = 'theTooltip';

	function Plugin() {
		var option = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];

		var namespace = 'lagden.' + pluginName;
		return this.each(function(idx, el) {
			var instance = $.data(el, namespace);
			if (instance) {
				if (typeof option === 'string' && /destroy/.test(option)) {
					$.removeData(el, namespace);
					instance[option]();
					instance = null;
				}
			} else if (typeof option !== 'string') {
				instance = new Tooltip(el, option);
				$.data(el, namespace, instance);
			}
		});
	}

	var old = $.fn[pluginName];

	$.fn[pluginName] = Plugin;
	$.fn[pluginName].Constructor = Tooltip;

	function noConflictTheTooltip() {
		$.fn[pluginName] = old;
		return this;
	}

	$.fn[pluginName].noConflict = noConflictTheTooltip;

});