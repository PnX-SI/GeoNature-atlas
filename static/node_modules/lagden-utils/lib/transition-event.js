'use strict';

import detect from './common/detect';

function transitionEvent() {
	const VENDOR = [
		['transition', 'transitionend'],
		['MozTransition', 'mozTransitionEnd'],
		['OTransition', 'oTransitionEnd'],
		['webkitTransition', 'webkitTransitionEnd']
	];
	return detect(VENDOR)[1];
}

export default transitionEvent;
