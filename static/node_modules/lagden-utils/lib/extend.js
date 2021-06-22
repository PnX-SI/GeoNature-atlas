'use strict';

function extend(a, b) {
	Object.keys(b).forEach(prop => {
		a[prop] = b[prop];
	});
	return a;
}

export default extend;
