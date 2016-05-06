package stockmarketedu;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class StudentTest {
	Student student;
	Supervisor supervisor;
	@Before
	public void setUp() throws Exception {
		supervisor = new Supervisor(); // manually put in an access code; 
		supervisor.getClassroom().setInitialMoney(1000.0);
		student = new Student("Sneha", "Email", supervisor.getClassroom().getInitialMoney()); 
		student.addCash(1000.0);
		supervisor.getClassroom().addStudent(student);
	}

	@Test
	public void testGetName() {
		assertEquals("Sneha", student.getName());
	}
	
	@Test
	public void testGetCashMoney(){
		String s = student.getCashMoney();
		assertEquals("2000.00", student.getCashMoney());
	}
	
	/*@Test
	public void testBuyPosition(){
		fail("don't know how to test this one");
	}
	
	@Test
	public void testSellPosition(){  
		fail("don't know how to test this");
		
	} */
	
	@Test
	public void testGetPortfolio(){
		java.util.ArrayList<Position> expected = new java.util.ArrayList<Position>();
		assertEquals(expected, student.getPortfolio());
	}
	
	@Test
	public void testGetMyHistory(){
		java.util.ArrayList<History> expected = new java.util.ArrayList<History>();
		assertEquals(expected, student.getMyHistory());
	}
	
	@Test
	public void testGetMaxProfitableSale(){ // nothing to look for
		assertTrue(student.getMaxProfitableSale() == Double.NEGATIVE_INFINITY);
	}
	
	@Test
	public void getMoney(){
		StudentStub student_s = (StudentStub) student;
		Market m = new MarketFacade();
		assertEquals(1000.0, student_s.getMoney(m), 0.01);
	}
	
	@Test
	public void testGetMaxProfitPerShare(){ // nothing to look for
		assertTrue(student.getMaxProfitPerShare() == Double.NEGATIVE_INFINITY);
	}
	

}
