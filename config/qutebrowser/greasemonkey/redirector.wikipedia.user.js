// ==UserScript==
// @name         wikipedia to indivious
// @namespace    https://gist.github.com/bitraid/d1901de54382532a03b9b22a207f0417
// @version      1.0
// @description  wikipedia to indivious
// @match        *://*.wikipedia.org/*
// @match        *://wikipedia.org/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
	'use strict';
	top.location.hostname = "wikiless.org";
})();
