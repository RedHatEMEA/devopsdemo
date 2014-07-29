package org.jboss.jdf.example.ticketmonster;


import org.jboss.jdf.example.ticketmonster.model.Performance;
import org.jboss.jdf.example.ticketmonster.model.Seat;
import org.jboss.jdf.example.ticketmonster.model.Section;
import org.jboss.jdf.example.ticketmonster.model.SectionAllocation;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SeatAlloactionTest {
	private static Logger LOGGER = LoggerFactory.getLogger(SeatAlloactionTest.class);
	Performance p = null;
	Section s = null;
	private static final int ROWS = 100;
	private static final int SEATS = 100;
	
	@Before
    public void prepareSection() throws Exception {
		p = new Performance();
		s = new Section();
		s.setNumberOfRows(100);
		s.setRowCapacity(100);
       
    }
	
	@Test 
	public void testAllocations() {
		
		SectionAllocation sa = new SectionAllocation(p,s);
		for(int i=0;i< ((ROWS*SEATS)/10);i++)
			sa.allocateSeats(10, true);
		
		Seat seat = new Seat(null,10,10);
		sa.deallocate(seat);

	}
	


}
