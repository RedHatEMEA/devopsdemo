define([
    'utilities',
    'configuration',
    'require',
    'text!../../../../templates/mobile/booking-details.html',
    'text!../../../../templates/mobile/create-booking.html',
    'text!../../../../templates/mobile/confirm-booking.html',
    'text!../../../../templates/mobile/ticket-entries.html',
    'text!../../../../templates/mobile/ticket-summary-view.html'
], function (
    utilities,
    config,
    require,
    bookingDetailsTemplate,
    createBookingTemplate,
    confirmBookingTemplate,
    ticketEntriesTemplate,
    ticketSummaryViewTemplate) {

    var TicketCategoriesView = Backbone.View.extend({
        id:'categoriesView',
        events:{
            "change input":"onChange"
        },
        render:function () {
            var views = {};

            if (this.model != null) {
                var ticketPrices = _.map(this.model, function (item) {
                    return item.ticketPrice;
                });
                utilities.applyTemplate($(this.el), ticketEntriesTemplate, {ticketPrices:ticketPrices});
            } else {
                $(this.el).empty();
            }
            return this;
        },
        onChange:function (event) {
            var value = event.currentTarget.value;
            var ticketPriceId = $(event.currentTarget).data("tm-id");
            var modifiedModelEntry = _.find(this.model, function(item) { return item.ticketPrice.id == ticketPriceId});
            if ($.isNumeric(value) && value > 0) {
                modifiedModelEntry.quantity = parseInt(value);
            }
            else {
                delete modifiedModelEntry.quantity;
            }
        }
    });

     var TicketSummaryView = Backbone.View.extend({
        render:function () {
            utilities.applyTemplate($(this.el), ticketSummaryViewTemplate, this.model.bookingRequest)
        }
    });

    var CreateBookingView = Backbone.View.extend({

        currentView: "CreateBooking",
        intervalDuration : 100,
        formValues : [],
        events:{
            "click a[id='confirmBooking']":"checkout",
            "change select":"refreshPrices",
            "change input[type='number']":"updateForm",
            "change input[name='email']":"updateForm",
            "click a[id='saveBooking']":"saveBooking",
            "click a[id='goBack']":"back",
            "click a[data-action='delete']":"deleteBooking"
        },
        render: function() {
            if (this.currentView === "CreateBooking") {
                this.renderCreateBooking();
            } else if(this.currentView === "ConfirmBooking") {
                this.renderConfirmBooking();
            }
            return this;
        },
        renderCreateBooking:function () {

            var self = this;

            $.getJSON(config.baseUrl + "rest/shows/" + this.model.showId, function (selectedShow) {
                self.model.performance = _.find(selectedShow.performances, function (item) {
                    return item.id == self.model.performanceId;
                });
                self.model.email = self.model.email || ""; 
                var id = function (item) {return item.id;};
                // prepare a list of sections to populate the dropdown
                var sections = _.uniq(_.sortBy(_.pluck(selectedShow.ticketPrices, 'section'), id), true, id);

                utilities.applyTemplate($(self.el), createBookingTemplate, { show:selectedShow,
                    performance:self.model.performance,
                    sections:sections,
                    email:self.model.email});
                $(self.el).enhanceWithin();
                self.ticketCategoriesView = new TicketCategoriesView({model:{}, el:$("#ticketCategoriesViewPlaceholder") });
                self.model.show = selectedShow;
                self.ticketCategoriesView.render();
                $('a[id="confirmBooking"]').addClass('ui-disabled');
                $("#sectionSelector").change();
                self.watchForm();
            });

        },
        refreshPrices:function (event) {
            if (event.currentTarget.value != "Choose a section") {
                var ticketPrices = _.filter(this.model.show.ticketPrices, function (item) {
                    return item.section.id == event.currentTarget.value;
                });
                var ticketPriceInputs = new Array();
                _.each(ticketPrices, function (ticketPrice) {
                    var model = {};
                    model.ticketPrice = ticketPrice;
                    ticketPriceInputs.push(model);
                });
                $("#ticketCategoriesViewPlaceholder").show();
                this.ticketCategoriesView.model = ticketPriceInputs;
                this.ticketCategoriesView.render();
                $(this.el).enhanceWithin();
            } else {
                $("#ticketCategoriesViewPlaceholder").hide();
                this.ticketCategoriesView.model = new Array();
                this.updateForm();
            }
        },
        checkout:function () {
            var savedTicketRequests = this.model.bookingRequest.tickets = this.model.bookingRequest.tickets || [];
            _.each(this.ticketCategoriesView.model, function(newTicketRequest){
                var matchingRequest = _.find(savedTicketRequests, function(ticketRequest) {
                    return ticketRequest.ticketPrice.id == newTicketRequest.ticketPrice.id;
                });
                if(newTicketRequest.quantity) {
                    if(matchingRequest) {
                        matchingRequest.quantity += newTicketRequest.quantity;
                    } else {
                        savedTicketRequests.push(newTicketRequest);
                    }
                }
            });
            this.model.bookingRequest.totals = this.computeTotals(this.model.bookingRequest.tickets);
            this.currentView = "ConfirmBooking";
            this.render();
        },
        updateForm:function () {
            var valid = true;
            this.model.email = $("input[type='email']").val();
            $("input[type='number']").each(function(idx,element) {
                var quantity = $(this).val();
                if(!$.isNumeric(quantity)  // is a non-number, other than empty string
                        || quantity <= 0 // is negative
                        || parseFloat(quantity) != parseInt(quantity)) {
                    $("#error-" + element.id).empty().append("Should be a positive number.");
                    $('a[id="confirmBooking"]').removeClass('ui-disabled');
                    valid = false;
                } else {
                    $("#error-" + element.id).empty();
                    $('a[id="confirmBooking"]').addClass('ui-disabled');
                }
            });
            try {
                var validElements = document.querySelectorAll(":valid");
                var $email = $("#email");
                var emailElem = $email.get(0);
                var validEmail = false;
                for (var ctr=0; ctr < validElements.length; ctr++) {
                    if (emailElem === validElements[ctr]) {
                        validEmail = true;
                    }
                }
                if(validEmail) {
                    this.model.email = $email.val();
                    $("#error-email").empty();
                } else {
                    $("#error-email").empty().append("Please enter a valid e-mail address");
                    delete this.model.email;
                    valid = false;
                }
            }
            catch(e) {
                // For browsers like IE9 that do fail on querySelectorAll for CSS pseudo selectors,
                // we use the regex defined in the HTML5 spec.
                var emailRegex = new RegExp("[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*");
                var emailValue = $("#email").val();
                if(emailRegex.test(emailValue)) {
                    this.model.email = emailValue;
                    $("#error-email").empty();
                } else {
                    $("#error-email").empty().append("Please enter a valid e-mail address");
                    delete this.model.email;
                    valid = false;
                }
            }
            var totals = this.computeTotals(this.ticketCategoriesView.model);
            if (totals.tickets > 0 && valid) {
                $('a[id="confirmBooking"]').removeClass('ui-disabled');
            } else {
                $('a[id="confirmBooking"]').addClass('ui-disabled');
            }
        },
        computeTotals: function(ticketRequestCollection) {
            var totals = _.reduce(ticketRequestCollection, function (partial, model) {
                if (model.quantity != undefined) {
                    partial.tickets += model.quantity;
                    partial.price += model.quantity * model.ticketPrice.price;
                    return partial;
                } else {
                    return partial;
                }
            }, {tickets:0, price:0.0});
            return totals;
        },
        renderConfirmBooking:function () {
            utilities.applyTemplate($(this.el), confirmBookingTemplate, this.model);
            this.ticketSummaryView = new TicketSummaryView({model:this.model, el:$("#ticketSummaryView")});
            this.ticketSummaryView.render();
            $(this.el).enhanceWithin();
            if (this.model.bookingRequest.totals.tickets > 0) {
                $('a[id="saveBooking"]').removeClass('ui-disabled');
            } else {
                $('a[id="saveBooking"]').addClass('ui-disabled');
            }
            return this;
        },
        back:function () {
            this.currentView = "CreateBooking";
            this.render();
        },
        saveBooking:function (event) {
            var bookingRequest = {ticketRequests:[]};
            var self = this;
            _.each(this.model.bookingRequest.tickets, function (model) {
                if (model.quantity != undefined) {
                    bookingRequest.ticketRequests.push({ticketPrice:model.ticketPrice.id, quantity:model.quantity})
                }
            });

            bookingRequest.email = this.model.email;
            bookingRequest.performance = this.model.performanceId;
            $.ajax({url:(config.baseUrl + "rest/bookings"),
                data:JSON.stringify(bookingRequest),
                type:"POST",
                dataType:"json",
                contentType:"application/json",
                success:function (booking) {
                    utilities.applyTemplate($(self.el), bookingDetailsTemplate, booking);
                    $(self.el).enhanceWithin();
                }}).error(function (error) {
                    try {
                        var response = JSON.parse(error.responseText);
                        var displayMessage = "";
                        if(response && response.errors) {
                            var errors = response.errors;
                            for(var idx = 0; idx < errors.length; idx++) {
                                displayMessage += errors[idx] + "\n";
                            }
                            alert(displayMessage);
                        } else {
                            alert("Failed to perform the bookng.");
                        }
                    } catch (e) {
                        alert("Failed to perform the bookng.");
                    }
                });
        },
        deleteBooking: function(event) {
            var deletedIdx = $(event.currentTarget).data("ticketpriceid");
            this.model.bookingRequest.tickets = _.reject(this.model.bookingRequest.tickets, function(ticketRequest) {
                return ticketRequest.ticketPrice.id == deletedIdx; 
            });
            this.model.bookingRequest.totals = this.computeTotals(this.model.bookingRequest.tickets);
            this.renderConfirmBooking();
            return false;
        },
        watchForm: function() {
            if($("#sectionSelect").length) {
                var self = this;
                $("input").each( function(index,element) {
                    if(element.value !== self.formValues[element.id]) {
                        self.formValues[element.id] = element.value;
                        $("input[id='"+element.id+"']").change();
                    }
                });
                this.timerObject = setTimeout(function() {
                    self.watchForm();
                }, this.intervalDuration);
            } else {
                this.onClose();
            }
        },
        onClose: function() {
            if(this.timerObject) {
                clearTimeout(this.timerObject);
                delete this.timerObject;
            }
        }
    });
    return CreateBookingView;
});