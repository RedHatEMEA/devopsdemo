define(['backbone'], function () {

    var AboutView = Backbone.View.extend({
        render:function () {
            $(this.el).empty().append("<section><h1>Welcome to Ticket Monster!</h1>" +
                "Ticket Monster is a demo application</section>");
            return this;
        }
    });

    return AboutView;

});