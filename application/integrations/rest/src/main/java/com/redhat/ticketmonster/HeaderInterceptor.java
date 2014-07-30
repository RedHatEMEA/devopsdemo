package com.redhat.ticketmonster;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.message.Message;
import org.apache.cxf.phase.AbstractPhaseInterceptor;
import org.apache.cxf.phase.Phase;

public class HeaderInterceptor extends AbstractPhaseInterceptor<Message> {

	public HeaderInterceptor() {
		super(Phase.MARSHAL);
	}

	@Override
	public void handleMessage(Message message) throws Fault {
		try {
			Map<String, List<String>> headers = (Map<String, List<String>>)message.get(Message.PROTOCOL_HEADERS);

			if(headers == null) {
				headers = new TreeMap<String, List<String>>(String.CASE_INSENSITIVE_ORDER);
				message.put(Message.PROTOCOL_HEADERS, headers);
			}

			Message in = message.getExchange().getInMessage();
			Map<String, List<String>> inh = (Map<String, List<String>>)in.get(Message.PROTOCOL_HEADERS);

			if(in.get(Message.HTTP_REQUEST_METHOD).equals("OPTIONS")) {
				headers.put("Access-Control-Allow-Methods", Arrays.asList("POST", "GET", "HEAD", "DELETE", "OPTIONS"));  //(List<String>)inh.get("Access-Control-Request-Method"));
				headers.put("Access-Control-Allow-Headers", (List<String>)inh.get("Access-Control-Request-Headers"));
				headers.put("Access-Control-Max-Age", Arrays.asList("10"));
			}

			List<String> o = (List<String>)inh.get("Origin");
			if(o == null) {
				headers.put("Access-Control-Allow-Origin", Arrays.asList("*"));
			} else {
				headers.put("Access-Control-Allow-Origin", o);
			}
			
		} catch (Exception e) {
			throw new Fault(e);
		}
	}

}
