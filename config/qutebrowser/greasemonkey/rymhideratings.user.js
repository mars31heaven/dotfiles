// ==UserScript==
// @name         RateYourMusic - Hide All Scores & Ratings
// @namespace    http://tampermonkey.net
// @version      1.3
// @description  Globally hides user scores, star breakdowns, and track ratings on RYM to prevent bias.
// @author       You
// @match        *://*.rateyourmusic.com/*
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

    const css = `
        /* Hide overall release ratings and star breakdowns */
        .album_info_rating,
        .release_page_rating_bar,
        .rating_num,
        .ui_rating_bar,
        .chart_stats,
        .stat_rating,
        .catalog_rating,

        /* Artist & Discography Page Selectors */
        .artist_page_release_rating,
        .artist_page_release_ratings,
        .artist_page_release_rating_num,
        .disco_sub_stat,
        .disco_stat,
        .page_artist_discography_rating,
        .page_artist_discography_ratings,
        .disco_avg_rating,
        .disco_num_ratings,

        /* General, Charts, and Search Selectors */
        .ratings,
        .chart_has_rating,
        span.avg_rating,
        span.rating_num {
            display: none !important;
        }

        /* Hide track-level ratings */
        .track_rating,
        .track_rating_num {
            display: none !important;
        }
    `;

    const style = document.createElement('style');
    style.type = 'text/css';
    style.appendChild(document.createTextNode(css));

    (document.head || document.documentElement).appendChild(style);

    // JS Fallback for dynamically added artist discography ratings
    const hideTextRatings = () => {
        // Target elements that contain "X.XX / 5" text on artist pages
        const elements = document.querySelectorAll('.disco_release, .artist_page_release, tr');
        elements.forEach(el => {
            if (el.textContent.includes(' / 5')) {
                // Find and hide specific child elements containing ratings
                const ratingNodes = el.querySelectorAll('span, b, td');
                ratingNodes.forEach(node => {
                    if (/\b\d\.\d{2}\b|\b\d\.\d{1}\b/.test(node.textContent) && node.children.length === 0) {
                        node.style.display = 'none';
                    }
                });
            }
        });
    };

    hideTextRatings();

    // Watch for dynamic updates (like toggling tabs on artist pages)
    const observer = new MutationObserver(hideTextRatings);
    observer.observe(document.body, { childList: true, subtree: true });
})();
