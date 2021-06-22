'use strict';

function detect(lista) {
	let i = 0;
	for (i = lista.length - 1; i >= 0; i--) {
		if (document.documentElement.style[lista[i][0]] !== undefined) {
			break;
		}
	}
	return lista[i];
}

export default detect;
