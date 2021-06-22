import $ from 'jquery';
import Tooltip from './tooltip';

const pluginName = 'theTooltip';

function Plugin(option = {}) {
	const namespace = `lagden.${pluginName}`;
	return this.each((idx, el) => {
		let instance = $.data(el, namespace);
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

const old = $.fn[pluginName];

$.fn[pluginName] = Plugin;
$.fn[pluginName].Constructor = Tooltip;

function noConflictTheTooltip() {
	$.fn[pluginName] = old;
	return this;
}

$.fn[pluginName].noConflict = noConflictTheTooltip;
