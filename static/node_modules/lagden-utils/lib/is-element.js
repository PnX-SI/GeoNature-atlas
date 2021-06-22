'use strict';

function isElement(obj) {
	return obj instanceof HTMLElement || obj instanceof SVGElement;
}
export default isElement;
