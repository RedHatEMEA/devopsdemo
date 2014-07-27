define([
    'utilities',
    'text!../../../../templates/mobile/booking-row.html',
    'require'
], function (
    utilities,
    bookingRowTemplate,
    require) {

    var BookingRowView = Backbone.View.extend({
        tagName:'li',
        events:{
            "click a[data-tm-role='delete']":"deleteBooking",
            "click ":"showDetails"
        },
        render:function () {
            utilities.applyTemplate($(this.el), bookingRowTemplate, this.model.attributes);
            return this;
        },
        deleteBooking:function (event) {
            if (confirm("Are you sure you want to delete booking " + this.model.get('id'))) {
                this.model.destroy();
            }
            event.stopPropagation();
            event.stopImmediatePropagation();
        },
        showDetails:function () {
            require('router').navigate("#bookings/" + this.model.get('id'), true);
        }
    });


    var BookingsView = Backbone.View.extend({
        render:function () {
            $(this.el).empty().append("<ul data-role='listview' id='bookingDetails'/>");
            _.each(this.model.models, function (booking) {
                var bookingView = new BookingRowView({model:booking});
                $("#bookingDetails").append(bookingView.render().el);
            });
            $("#bookingDetails").listview();
            $(this.el).enhanceWithin();
        }
    });

    return BookingsView;

});