'use strict';

import {qS, textNode, isElement, extend} from 'lagden-utils';

// Helpers
const isCSS1Compat = ((document.compatMode || "") === "CSS1Compat");
const body = document.body || qS('body');

// Internal store of all Tooltip intances
const instances = {};

// Globally unique identifiers
let GUID = 0;

class Tooltip {
	constructor(target, opts = {}) {
		this.target = isElement(target) ? target : qS(target);

		// Check if element was initialized and return your instance
		const initialized = Tooltip.data(this.target);
		if (initialized instanceof Tooltip) {
			return initialized;
		}

		// Storage current instance
		const id = ++GUID;
		this.target.GUID = id;
		instances[id] = this;

		this.options = {
			attr: 'data-lagden-tip',
			content: false,
			html: false,
			css: 'theTooltip',
			place: 'auto',
			space: 15,
			fixed: false
		};
		this.options = extend(this.options, opts);

		const tip = this.options.content || this.target.getAttribute(this.options.attr);
		this.tooltip = textNode(document.createElement('div'), tip, this.options.html);
		this.tooltip.classList.add(this.options.css);
		if (this.options.fixed) {
			this.tooltip.style.position = 'fixed';
		}

		body.appendChild(this.tooltip);

		this.target.addEventListener('mouseenter', this, false);
		this.target.addEventListener('mouseleave', this, false);
		this.target.addEventListener('click', this, false);
	}

	show() {
		let y;
		let scrollY = window.pageYOffset || isCSS1Compat ? document.documentElement.scrollTop : body.scrollTop;
		const place = this.options.place;
		const tgBounds = this.target.getBoundingClientRect();
		const ttBounds = this.tooltip.getBoundingClientRect();
		const ttBody = (ttBounds.height + this.options.space).toFixed(0) - '';
		const check = tgBounds.top - ttBody;
		const center = (tgBounds.left + ((tgBounds.width / 2) - (ttBounds.width / 2))).toFixed(0) - '';

		if (this.options.fixed) {
			scrollY = 0;
		}

		if ((check < 0 || place === 'bottom') && place !== 'top') {
			y = tgBounds.top + tgBounds.height + scrollY + this.options.space;
			this.tooltip.classList.add(`${this.options.css}--top`);
		} else {
			y = tgBounds.top + scrollY - ttBody;
			this.tooltip.classList.remove(`${this.options.css}--top`);
		}

		this.tooltip.style.top = `${y}px`;
		this.tooltip.style.left = `${center}px`;
		this.tooltip.classList.add(`${this.options.css}--show`);
	}

	hide() {
		this.tooltip.classList.remove(`${this.options.css}--show`);
	}

	destroy() {
		this.target.removeEventListener('mouseenter', this, false);
		this.target.removeEventListener('mouseleave', this, false);
		this.target.removeEventListener('click', this, false);

		body.removeChild(this.tooltip);

		const id = this.target.GUID;
		delete instances[id];
		delete this.target.GUID;
	}

	handleEvent(event) {
		switch (event.type) {
			case 'mouseenter':
				this.show(event);
				break;
			case 'mouseleave':
			case 'click':
				this.hide(event);
				break;
			default:
				break;
		}
	}
}

Tooltip.data = el => {
	const id = el && el.GUID;
	return id && instances[id];
};

export default Tooltip;
