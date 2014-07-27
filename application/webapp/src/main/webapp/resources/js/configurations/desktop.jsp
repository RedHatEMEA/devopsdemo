<%@ page language="java" contentType="application/javascript" %>
/**
 * Shortcut alias definitions - will come in handy when declaring dependencies
 * Also, they allow you to keep the code free of any knowledge about library
 * locations and versions
 */
requirejs.config({
    baseUrl: "resources/js",
    paths: {
        jquery:'libs/jquery-2.0.3',
        underscore:'libs/underscore',
        text:'libs/text',
        bootstrap: 'libs/bootstrap',
        backbone: 'libs/backbone',
        utilities: 'app/utilities',
        router:'app/router/desktop/router'
    },
    // We shim Backbone.js and Underscore.js since they don't declare AMD modules
    shim: {
        'backbone': {
            deps: ['jquery', 'underscore'],
            exports: 'Backbone'
        },
        
        'underscore': {
        	exports: '_'
        }
    }
});

define("initializer", ["jquery"], function ($) {
    // Configure jQuery to append timestamps to requests, to bypass browser caches
    // Important for MSIE
	$.ajaxSetup({cache:false});
    $('head').append('<link rel="stylesheet" href="resources/css/bootstrap.css" type="text/css" media="all"/>');
    $('head').append('<link rel="stylesheet" href="resources/css/bootstrap-theme.css" type="text/css" media="all"/>');
    $('head').append('<link rel="stylesheet" href="resources/css/screen.css" type="text/css" media="all"/>');
    $('head').append('<link href="http://fonts.googleapis.com/css?family=Rokkitt" rel="stylesheet" type="text/css">');
});

// Now we declare all the dependencies
// This loads and runs the 'initializer' and 'router' modules.
require([
    'initializer',
    'router'
], function(){
});

define("configuration", {
    baseUrl : "<%= System.getenv("BASEURL") %>"
});
