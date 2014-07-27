define(['underscore', 'backbone'], function (_, Backbone) {

    var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    var monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];


    Date.prototype.toPrettyString = function () {
        return dayNames[this.getDay()] + " " +
            this.getDate() + " " +
            monthNames[this.getMonth()] + " " +
            this.getFullYear() + " at " +
            this.getHours().toZeroPaddedString(2) + ":" +
            this.getMinutes().toZeroPaddedString(2);
    };

    Date.prototype.toPrettyStringWithoutTime = function () {
        return dayNames[this.getDay()] + " " +
            this.getDate() + " " +
            monthNames[this.getMonth()] + " " +
            this.getFullYear();
    };

    Date.prototype.toYMD = function () {
        return this.getFullYear() + '-' + (this.getMonth() + 1).toZeroPaddedString(2) + '-' + this.getDate().toZeroPaddedString(2);
    };

    Date.prototype.toCalendarDate = function () {
        return { 'day':this.getDate(), 'month':this.getMonth(), 'year':this.getFullYear()};
    };

    Date.prototype.withoutTimeOfDay = function () {
        return new Date(this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0, 0);
    };

    Date.prototype.asArray = function () {
        return [this.getFullYear(), this.getMonth(), this.getDate()];
    };


    Date.prototype.toTimeOfDay = function () {
        return { 'hours':this.getHours(), 'minutes':this.getMinutes(),
            'seconds':this.getSeconds(), 'milliseconds':this.getMilliseconds()};
    };

    Date.prototype.diff = function (other) {
        return parseInt((this.withoutTimeOfDay().getTime() - other.withoutTimeOfDay().getTime()) / (1000.0 * 60 * 60 * 24));
    };

    Number.prototype.toZeroPaddedString = function (digits) {
        val = this + "";
        while (val.length < digits) val = "0" + val;
        return val;
    };

    Backbone.View.prototype.close = function(){
        $(this.el).empty();
        this.undelegateEvents();
        if (this.onClose){
            this.onClose();
        }
    };

    // utility functions for rendering templates
    var utilities = {
        viewManager:{
            currentView:null,

            showView:function (view) {
                if (this.currentView != null) {
                    this.currentView.close();
                }
                this.currentView = view;
                return this.currentView.render();
            }
        },
        renderTemplate:function (template, data) {
            return _.template(template, (data == undefined) ? {} : data);
        },
        applyTemplate:function (target, template, data) {
            return target.empty().append(this.renderTemplate(template, data));
        },
        displayAlert: function(msg) {
            if(navigator.notification) {
                navigator.notification.alert(msg);
            } else {
                alert(msg);
            }
        }
    };

    return utilities;

});