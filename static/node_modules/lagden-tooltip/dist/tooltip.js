define(function() {
	'use strict';

	var babelHelpers = {};

	babelHelpers.classCallCheck = function(instance, Constructor) {
		if (!(instance instanceof Constructor)) {
			throw new TypeError("Cannot call a class as a function");
		}
	};

	babelHelpers.createClass = function() {
		function defineProperties(target, props) {
			for (var i = 0; i < props.length; i++) {
				var descriptor = props[i];
				descriptor.enumerable = descriptor.enumerable || false;
				descriptor.configurable = true;
				if ("value" in descriptor)
					descriptor.writable = true;
				Object.defineProperty(target, descriptor.key, descriptor);
			}
		}

		return function(Constructor, protoProps, staticProps) {
			if (protoProps) defineProperties(Constructor.prototype, protoProps);
			if (staticProps) defineProperties(Constructor, staticProps);
			return Constructor;
		};
	}();

	babelHelpers;

	function extend(a, b) {
		Object.keys(b).forEach(function(prop) {
			a[prop] = b[prop];
		});
		return a;
	}

	function isElement(obj) {
		return obj instanceof HTMLElement;
	}

	function qS(el) {
		return document.querySelector(el);
	}

	function textNode(node, txt) {
		var stringHTML = arguments.length <= 2 || arguments[2] === undefined ? false : arguments[2];

		if (stringHTML) {
			node.insertAdjacentHTML('afterbegin', txt);
		} else {
			node.appendChild(document.createTextNode(txt));
		}
		return node;
	}

	// Helpers
	var isCSS1Compat = (document.compatMode || "") === "CSS1Compat";
	var body = document.body || qS('body');

	// Internal store of all Tooltip intances
	var instances = {};

	// Globally unique identifiers
	var GUID = 0;

	var Tooltip = function() {
		function Tooltip(target) {
			var opts = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];
			babelHelpers.classCallCheck(this, Tooltip);

			this.target = isElement(target) ? target : qS(target);

			// Check if element was initialized and return your instance
			var initialized = Tooltip.data(this.target);
			if (initialized instanceof Tooltip) {
				return initialized;
			}

			// Storage current instance
			var id = ++GUID;
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

			var tip = this.options.content || this.target.getAttribute(this.options.attr);
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

		babelHelpers.createClass(Tooltip, [{
			key: 'show',
			value: function show() {
				var y = void 0;
				var scrollY = window.pageYOffset || isCSS1Compat ? document.documentElement.scrollTop : body.scrollTop;
				var place = this.options.place;
				var tgBounds = this.target.getBoundingClientRect();
				var ttBounds = this.tooltip.getBoundingClientRect();
				var ttBody = (ttBounds.height + this.options.space).toFixed(0) - '';
				var check = tgBounds.top - ttBody;
				var center = (tgBounds.left + (tgBounds.width / 2 - ttBounds.width / 2)).toFixed(0) - '';

				if (this.options.fixed) {
					scrollY = 0;
				}

				if ((check < 0 || place === 'bottom') && place !== 'top') {
					y = tgBounds.top + tgBounds.height + scrollY + this.options.space;
					this.tooltip.classList.add(this.options.css + '--top');
				} else {
					y = tgBounds.top + scrollY - ttBody;
					this.tooltip.classList.remove(this.options.css + '--top');
				}

				this.tooltip.style.top = y + 'px';
				this.tooltip.style.left = center + 'px';
				this.tooltip.classList.add(this.options.css + '--show');
			}
		}, {
			key: 'hide',
			value: function hide() {
				this.tooltip.classList.remove(this.options.css + '--show');
			}
		}, {
			key: 'destroy',
			value: function destroy() {
				this.target.removeEventListener('mouseenter', this, false);
				this.target.removeEventListener('mouseleave', this, false);
				this.target.removeEventListener('click', this, false);

				body.removeChild(this.tooltip);

				var id = this.target.GUID;
				delete instances[id];
				delete this.target.GUID;
			}
		}, {
			key: 'handleEvent',
			value: function handleEvent(event) {
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
		}]);
		return Tooltip;
	}();

	Tooltip.data = function(el) {
		var id = el && el.GUID;
		return id && instances[id];
	};

	return Tooltip;

});