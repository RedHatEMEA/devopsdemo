package com.redhat.ticketmonster;

import javax.jms.Connection;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.TextMessage;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.jboss.jdf.example.ticketmonster.model.Booking;
import org.jboss.jdf.example.ticketmonster.model.Ticket;

public class BookingNotifier {
	public static void notify(Booking booking) {
		try {
			ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory("admin", "admin", "tcp://localhost:61616");

			Connection connection = connectionFactory.createConnection();
			connection.start();

			Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
			Destination destination = session.createQueue("bookings");

			MessageProducer producer = session.createProducer(destination);
			producer.setDeliveryMode(DeliveryMode.NON_PERSISTENT);

			StringBuilder sb = new StringBuilder();
			sb.append("Dear " + booking.getContactEmail() + ",\n");
			sb.append("\n");
			sb.append("You have successfully booked the following tickets for:\n");
			sb.append("\n");
			sb.append("  ** " + booking.getPerformance() + " **\n");
			sb.append("\n");
			for(Ticket t : booking.getTickets()) {
				sb.append("    " + t.getTicketCategory() + ", " + t.getSeat() + " @ $" + t.getPrice() + "\n");
			}
			sb.append("\n");
			sb.append("Enjoy the show!\n");
			sb.append("\n");
			sb.append("Yours, TICKETMONSTER\n");
			
			String text = "<customer><email>" + booking.getContactEmail() + "</email><message>" + sb + "</message></customer>";
			TextMessage message = session.createTextMessage(text);
			producer.send(message);

			session.close();
			connection.close();
		} catch (JMSException e) {
			/* never mind for now */
		}
	}
}
