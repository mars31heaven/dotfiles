// ==UserScript==
// @name         youtube to indivious
// @namespace    https://gist.github.com/bitraid/d1901de54382532a03b9b22a207f0417
// @version      1.0
// @description  youtube to indivious
// @match        *://*.youtube.com/*
// @match        *://youtube.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
	'use strict';
	top.location.hostname = "vid.puffyan.us";
})();
