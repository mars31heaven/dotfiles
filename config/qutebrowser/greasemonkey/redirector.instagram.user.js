// ==UserScript==
// @name         instagram to bibliogram
// @namespace    https://gist.github.com/bitraid/d1901de54382532a03b9b22a207f0417
// @version      1.0
// @description  instagram to bibliogram
// @match        *://*.instagram.com/*
// @match        *://instagram.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
	'use strict';
	top.location.hostname = "bibliogram.art";
})();
