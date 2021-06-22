'use strict';

import detect from './common/detect';

function animationEvent() {
	const VENDOR = [
		[
			'animation',
			'animationstart',
			'animationiteration',
			'animationend'
		], [
			'MozAnimation',
			'mozAnimationStart',
			'mozAnimationIteration',
			'mozAnimationEnd'
		], [
			'OAnimation',
			'oAnimationStart',
			'oAnimationIteration',
			'oAnimationEnd'
		], [
			'webkitAnimation',
			'webkitAnimationStart',
			'webkitAnimationIteration',
			'webkitAnimationEnd'
		]
	];
	return detect(VENDOR);
}

export default animationEvent;
