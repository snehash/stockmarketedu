<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.googlecode.objectify.*" %>

<%@ page import="stockmarketedu.Supervisor" %>
<%@ page import="stockmarketedu.Student" %>
<%@ page import="stockmarketedu.Class" %>
<%@ page import="stockmarketedu.Position" %>
<%@ page import="stockmarketedu.Stock" %>
<%@ page import="stockmarketedu.History" %>
<%@ page import="stockmarketedu.Market" %>
<%@ page import="stockmarketedu.MarketFacade" %>

<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.NumberFormat"%>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE HTML>
<html>
	<head>
		<title>StockMarketEdu</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		<link href='https://fonts.googleapis.com/css?family=Nunito' rel='stylesheet' type='text/css'>
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:300,800" rel="stylesheet" type="text/css" />
		<link href="http://fonts.googleapis.com/css?family=Oleo+Script:400" rel="stylesheet" type="text/css" />
		<script src="js/jquery.min.js"></script>
		<script src="js/config.js"></script>
		<script src="js/skel.min.js"></script>
		<script src="js/skel-panels.min.js"></script>
		<noscript>
			<link rel="stylesheet" href="css/skel-noscript.css" />
			<link rel="stylesheet" href="css/style.css" />
			<link rel="stylesheet" href="css/style-desktop.css" />
		</noscript>
	</head>
	<%
	    UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();

	    ObjectifyService.register(Supervisor.class);
	    ObjectifyService.register(Market.class);
	    ObjectifyService.register(MarketFacade.class);

	    List<Supervisor> teachers = ObjectifyService.ofy().load().type(Supervisor.class).list(); 
	    boolean signedIn = false;
	    boolean inClass = false;
	    int teacherIndex = -1;
	    Student student = null;
	    ArrayList<String> permittedStocks = new ArrayList<String>();
	    String permittedStocksString = new String("");

	    NumberFormat formatter = new DecimalFormat("#0.00");

	    Market mkt = Market.getInstance();

		if (user != null) {
	    	pageContext.setAttribute("user", user);
	    	signedIn = true;
	    	for(Supervisor teacher: teachers) {
	    		for(String email: teacher.getStudentEmails()) {
	    			email = email.toLowerCase();
	    			System.out.println(email);
	    			if(email.equals(user.getEmail().toLowerCase())) {
	    				boolean found = false;
	    				for(Student stud: teacher.getClassroom().getMyClass()) {
	    					if(stud.getEmail().toLowerCase().equals(email)) {
	    						student = stud;
	    						found = true;
	    						break;
	    					}
	    				}
	    				if(!found) {
	    					double startCash = teacher.getClassroom().getInitialMoney();
	    					Student temp = new Student(user.getNickname(), email, startCash);
	    					student = temp;
	    					teacher.getClassroom().addStudent(student);
	    					ObjectifyService.ofy().save().entity(teacher).now();
	    				}
	    				inClass = true;
	    				for(Stock stk: teacher.getClassroom().getStocksAllowed()) {
	    					permittedStocks.add(stk.getSymbol());
	    					permittedStocksString += stk.getSymbol() + " ";
	    				}
	    				break;
	    			}
	    		}
	    		if(student != null) {
	    			break;
	    		}
	    	}
		}
		pageContext.setAttribute("permitted_stocks", permittedStocksString);
	%>
	<body class="left-sidebar">

		<div id="header-wrapper">
			<div class="container">
				<header id = "header" class = "header">
					<div class = "row">
						<div class = "12u">
						<header id="header" class="header">
												
							<div id="logo">
								<h2><a href="/">StockMarketEdu</a><h2>
							</div>
							<nav id="nav">
								<ul>
									<li ><a href="/">Home</a></li>
									<li class="current_page_item" ><a href="/student.jsp">Student Portal</a></li>
									<li ><a href="/teacher.jsp">Teacher Portal</a></li>
								</ul>
							</nav>
						</header>
						<%
							if(signedIn) {
						%>
							<span style="float:right"><a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">Sign out</a></span>
						<%
							}
						%>
					</div>
				</div>
			</div>
		</div>
		<div id="feature-wrapper">
			<div class="container">
				<div class="row">

					<div class="12u skel-cell-important">
						<h2 class="title">Student Portal</h2>
					</div>
				</div>

				<div class="row">
					<%
						if(signedIn && inClass) {
							pageContext.setAttribute("student_name", student.getName());
							pageContext.setAttribute("student_money", formatter.format(student.getMoney()));
							pageContext.setAttribute("student_cash", student.getCashMoney());							
					%>
						<div class="3u">
							<article class="info">
								<p class="byline">View your summary</p>
							</article>
							<article class="box">
								<ul>
									<li>Student: ${student_name}</li>
									<li>Investment Value: $${student_money}</li>
									<li>Cash: $${student_cash}</li>
								</ul>
							</article>
						</div>
						<div class="6u">
							<article class="info">
								<p class="byline">View your trade history</p>
							</article>
							<article class="box" id="history">
								<ul>
									<%
										ArrayList<History> history = student.getMyHistory();
										for(int i = history.size() - 1; i >= 0; i--) {
											History hist = history.get(i);
											double bought = hist.getPriceBought();
											double sold = hist.getPriceSold();
											String symbol = hist.getStockSymbol();
											double shares = hist.getShares();
											pageContext.setAttribute("hist_symbol", symbol);
											pageContext.setAttribute("hist_shares", shares);
											pageContext.setAttribute("hist_sell_price", formatter.format(sold));
											pageContext.setAttribute("hist_buy_price", formatter.format(bought));
											%>
												<li>
													${hist_symbol}&#58; ${hist_shares} share(s) bought at ${hist_buy_price}, sold at ${hist_sell_price}
												</li>
											<%
										}
									%>
								</ul>
							</article>
						</div>
						<div class="3u">
							<article class="info">
								<p class="byline">View your current holdings</p>
							</article>
							<article class="box">
								<ul>
									<%
										for(Position p: student.getPortfolio()) {
											pageContext.setAttribute("stock_symbol", p.getStockType().getSymbol());
											pageContext.setAttribute("stock_shares", p.getShares());
											pageContext.setAttribute("stock_price", formatter.format(mkt.getStock(p.getStockType().getSymbol()).getPrice()));
									%>
											<li>
												${stock_symbol}&#58; ${stock_shares} shares @ $${stock_price}
											</li>
									<%
										}
									%>
								</ul>
							</article>
						</div>
					<%
						} else if(!signedIn){
					%>
						<div class="12u">
							<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in to view performance</a>
						</div>
					<%
						} else {
					%>
						<div class="12u">
							Your email is not associated with a valid class. Please talk to your teacher.
						</div>
					<%
						}
					%>
				</div>
				<%
					if(signedIn && inClass) {
				%>

				<div class="row">
					<div class="4u">
						<article class="info">
							<p class="byline">Current market environment</p>
						</article>
						<article class="box">
							<ul>
								<%
									for(String stk: permittedStocks) {
										pageContext.setAttribute("current_stk_sym", stk);
										pageContext.setAttribute("current_stk_price", mkt.getStock(stk).getPrice());
								%>
								<li>${current_stk_sym}&#58; $${current_stk_price} per share</li>
								<%
									}
								%>
							</ul>
						</article>
					</div>
					<div class="4u">
						<article class="info">
							<p class="byline">Buy a stock</p>
						</article>
						<article class="box">
							<script>
								function validateBuyComplete() {
									var fields = Boolean(validateBuyStock());
									if(!fields) {
										return false;
									}
									var permits = Boolean(validateStockSymbolBuy());
									if(!permits) {
										return false;
									}
									return true;
								}
							</script>
							<form action="/buystock" method="post" name="buystock" onsubmit="return validateBuyComplete()">
								Stock Ticker<br> <input type="text" name="Stock Ticker"><br>
								Number of Shares<br> <input type="text" name="Number of Shares"><br>
								<input type="submit" value="Submit">
							</form>
						</article>
					</div>
					<div class="4u">
						<article class="info">
							<p class="byline">Sell a stock</p>
						</article>
						<article class="box">
							<script>
								function validateSellComplete() {
									var fields = Boolean(validateSellStock());
									if(!fields) {
										return false;
									}
									var permits = Boolean(validateStockSymbolSell());
									if(!permits) {
										return false;
									}
									return true;
								}
							</script>
							<form action="/sellstock" method="post" name="sellstock" onsubmit="return validateSellComplete()">
								Stock Ticker<br> <input type="text" name="Stock Ticker"><br>
								Number of Shares<br> <input type="text" name="Number of Shares"><br>
								<input type="submit" value="Submit">
							</form>
						</article>
					</div>
				</div>
				<%
					}
				%>

				<div class="row">

					<div class="12u">
						<article class="info">
							<p class="byline">Learn about the stock market</p>
						</article>
						<article class="box">
							<p id="student-fact">
								Enable javascript to see this fact!
							</p>
							<p style="font-style:italic;">
								From <a href="http://www.themint.org/kids/what-is-the-stock-market.html">themint.org</a>
							</p>
						</article>
					</div>

				</div>

			</div>
		</div>

	</body>
	<script>
		function validateStockSymbolBuy() {
			var ticker = document.forms["buystock"]["Stock Ticker"].value;
			var allowed = "${permitted_stocks}";
			var stocks = allowed.split(" ");
			for(var j = 0; j < stocks.length; j++) {
				if(ticker === stocks[j]) {
					return true;
				}
			}	
			alert(ticker + " is not a permitted stock");
			return false;
		}
	</script>
	<script>
		function validateStockSymbolSell() {
			var ticker = document.forms["sellstock"]["Stock Ticker"].value;
			var allowed = "${permitted_stocks}";
			var stocks = allowed.split(" ");
			for(var j = 0; j < stocks.length; j++) {
				if(ticker === stocks[j]) {
					return true;
				}
			}
			alert(ticker + " is not a permitted stock");
			return false;
		}
	</script>
	<script src="js/studentfacts.js"></script>
	<script src="js/validate.js"></script>
</html>