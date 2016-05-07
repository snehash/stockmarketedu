package stockmarketedutest;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class PositionTest {
	StockStub s;
	PositionStub pos;
	@Before
	public void setUp() throws Exception {
		s = new StockStub("Google", 10.50, "GOOG", new java.util.Date(), 5, true);
		pos = new PositionStub(s, 50); // did we forget to add this.shares = shares for the constructor?
	}

	@Test
	public void testSellShare(){
		HistoryStub h;
		//try{
			h = pos.sellShares(s.getDividendShare() + .01, new StockStub()); // this should throw an exception
		/*} catch (Exception e){
			assertTrue(true); 
		}*/
		HistoryStub expected = new HistoryStub ("GOOG", 4, 10.50, 10.50);
		h = pos.sellShares(4, new StockStub());
		assertEquals(expected.getStockSymbol(), h.getStockSymbol()); 
		assertEquals(expected.getPriceBought(), h.getPriceBought(), 0.01);
		assertEquals(expected.getPriceSold(), h.getPriceSold(), 0.01);
		assertEquals(expected.getShares(), h.getShares(), 1.0);
	}
	
	@Test
	public void testGetStockType(){
		assertEquals(s, pos.getStockType());
	}
	
	@Test
	public void testGetPriceBought(){
		assertTrue(10.50 == pos.getPriceBought());
	}
	
	@Test
	public void testgetShares(){
		assertTrue(50 == pos.getShares());
	}
	
	@Test
	public void testAddShare(){ 
		double num = 10.5;
		pos.addShares(7);
		assertTrue(num == pos.getPriceBought()); // hopefully I did the math correctly?
	}

}
