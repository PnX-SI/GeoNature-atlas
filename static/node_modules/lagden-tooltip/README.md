# Tooltip 
[![Build Status][ci-img]][ci]
[![Dependency Status][dep-img]][dep]
[![devDependency Status][devDep-img]][devDep]

[ci-img]:     https://travis-ci.org/lagden/tooltip.svg
[ci]:         https://travis-ci.org/lagden/tooltip
[cover-img]:  https://codecov.io/github/lagden/tooltip/coverage.svg?branch=master
[cover]:      https://codecov.io/github/lagden/tooltip?branch=master
[dep-img]:    https://david-dm.org/lagden/tooltip/dev-status.svg
[dep]:        https://david-dm.org/lagden/tooltip#info=devDependencies
[devDep-img]: https://david-dm.org/lagden/tooltip/dev-status.svg
[devDep]:     https://david-dm.org/lagden/tooltip#info=devDependencies

A simple tooltip

## Install

`AMD` and `ES6` via [NPM](https://www.npmjs.com/)  

```
npm i -S lagden-tooltip
```

Only `AMD` via [bower](https://bower.io/) 

```
bower install -S lagden-tooltip
```


## API

### Methods

There are three methods: `show`, `hide` and `destroy`.

### Options

Some options can be passed when initialize:

| Option | Description | Default |
| --- | --- | --- |
| attr | Specify from whence come the value | `'data-lagden-tip'` |
| content | Custom value | `false` |
| html | Escaping your value | `false` |
| css | The component stylesheet class name | `'theTooltip'` |
| place | Force the place where shown the tooltip. Possibles values: `auto`, `top` and `bottom` | `'auto'` |
| space | Add some space between target and tooltip | `15` |
| fixed | Avoid position error if the target is fixed or is within a fixed element | `false` |

## Usage

There are two ways:

### Vanilla

```javascript
var t = document.querySelector('#el');
var tooltip = new Tooltip(t, {content: 'Example!'});
```

### jQuery

```javascript
var $t = $('#el');
$t.theTooltip({
  content: '<h3>Title</h3><p>Some pretty cool stuff!</p>',
  html: true
});
```


## Stylesheet

Take a look on [stylus/tooltip.styl](https://github.com/lagden/tooltip/blob/master/stylus/tooltip.styl) file.


## Example

See [here](http://lagden.github.io/tooltip/).
![Example](https://raw.githubusercontent.com/lagden/tooltip/master/animation.gif)


## License

MIT © [Thiago Lagden](http://lagden.in)
