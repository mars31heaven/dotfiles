// ==UserScript==
// @name         twitter to nitter
// @namespace    https://gist.github.com/bitraid/d1901de54382532a03b9b22a207f0417
// @version      1.0
// @description  twitter to nitter
// @match        *://*.twitter.com/*
// @match        *://twitter.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
	'use strict';
	top.location.hostname = "twtr.domain.glass";
})();
