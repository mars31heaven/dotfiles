// ==UserScript==
// @name         Hide Letterboxd Ratings & Reviews
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Hides star ratings, average scores, and written reviews on Letterboxd
// @author       You
// @match        https://letterboxd.com/*
// @match        https://*.letterboxd.com/*
// @grant        none
// ==UserScript==

(function() {
    'use strict';

    // Inject CSS to instantly hide rating and review elements across the site
    const style = document.createElement('style');
    style.textContent = `
        /* --- HIDE RATINGS & HISTOGRAMS --- */
        .average-rating,
        .rating-histogram,
        .rating-histogram-clear,
        section.ratings-histogram-chart,
        .rating,
        .stars,
        span.rating,
        .display-rating,
        .td-rating,
        .poster-view .rating,

        /* --- HIDE WRITTEN REVIEWS --- */
        /* Film pages: hides popular/recent review sections */
        .film-reviews,
        #section-reviews,
        section.reviews-section,

        /* Activity feed & User profile pages: hides review text blocks */
        .body-text.-prose,
        .comment-text,
        .review .body-text,
        ul.review-list,

        /* Member log entries & Recent reviews widgets */
        .film-detail-content .body-text,
        .sidebar .section.reviews {
            display: none !important;
        }
    `;
    (document.head || document.documentElement).appendChild(style);
})();
