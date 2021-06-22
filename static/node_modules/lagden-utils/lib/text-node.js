'use strict';

function textNode(node, txt, stringHTML = false) {
	if (stringHTML) {
		node.insertAdjacentHTML('afterbegin', txt);
	} else {
		node.appendChild(document.createTextNode(txt));
	}
	return node;
}

export default textNode;
