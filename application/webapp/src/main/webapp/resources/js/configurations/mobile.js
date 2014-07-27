/**
 * Shortcut alias definitions - will come in handy when declaring dependencies
 * Also, they allow you to keep the code free of any knowledge about library
 * locations and versions
 */
require.config({
    baseUrl:"resources/js",
    paths: {
        jquery:'libs/jquery-2.0.3',
        jquerymobile:'libs/jquery.mobile-1.4.2',
        text:'libs/text',
        underscore:'libs/underscore',
        backbone: 'libs/backbone',
        order: 'libs/order',
        utilities: 'app/utilities',
        router:'app/router/mobile/router'
    },
    // We shim Backbone.js and Underscore.js since they don't declare AMD modules
    shim: {
        'backbone': {
            deps: ['underscore', 'jquery'],
            exports: 'Backbone'
        },
        
        'underscore': {
        	exports: '_'
        }
    }
});

define("configuration", function() {
    if (window.TicketMonster != undefined && TicketMonster.config != undefined) {
        return {
            baseUrl: TicketMonster.config.baseRESTUrl
        };
    } else {
        return {
            baseUrl: ""
        };
    }
});

define("initializer", [
    'jquery',
    'utilities',
    'text!../templates/mobile/main.html'
], function ($,
             utilities,
             MainTemplate) {
    // Configure jQuery to append timestamps to requests, to bypass browser caches
    // Important for MSIE
	$.ajaxSetup({cache:false});
    $('head').append('<link rel="stylesheet" href="resources/css/jquery.mobile-1.4.2.css"/>');
    $('head').append('<link rel="stylesheet" href="resources/css/m.screen.css"/>');
    // Bind to mobileinit before loading jQueryMobile
    $(document).bind("mobileinit", function () {
        // Prior to creating and starting the router, we disable jQuery Mobile's own routing mechanism
        $.mobile.hashListeningEnabled = false;
        $.mobile.linkBindingEnabled = false;
        $.mobile.pushStateEnabled = false;
        
        // Fix jQueryMobile header and footer positioning issues for iOS.
        // See: https://github.com/jquery/jquery-mobile/issues/4113 and
        // https://github.com/jquery/jquery-mobile/issues/5532
        $(document).on('blur', 'input, textarea, select', function() {
            setTimeout(function() {
            window.scrollTo(document.body.scrollLeft, document.body.scrollTop);
            }, 0);
        });
        
        utilities.applyTemplate($('body'), MainTemplate);
    });
    // Then (load jQueryMobile and) start the router to finally start the app
    require(['router']);
});

// Now we declare all the dependencies
// This loads and runs the 'initializer' module.
require(['initializer']);
