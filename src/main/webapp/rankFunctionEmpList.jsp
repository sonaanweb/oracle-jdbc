<%@page import="oracle.net.aso.r"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*"%>
<%@ page import ="java.util.*"%>
<%

	/*select employee_id, last_name, salary, rank() over(order by salary desc) 급여순위 from employees;*
	[이전]1 2 3 ...[다음] 페이징 작업까지 */
	
	// 페이징
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage")); //"문자열"이니까 integer로 바꿔준다
	}
	
	// DB연동 
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	int totalRow = 0; // 테이블 총 행
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	
	if(totalRowRs.next()){ // 결과값
		totalRow = totalRowRs.getInt("count(*)"); // totalRowRs.getInt("count(*)")
	}
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1; // beginrow 1부터 시작
	int endRow = beginRow + (rowPerPage - 1); // 보여지는 각 페이지중 마지막 행
	if(endRow > totalRow) { 
		endRow = totalRow;
	}
	
	// 페이징 쿼리 ----------- 급여순위 순으로 페이징 = where 급여순위 ~ 
	String rankSql = "select 직원ID, 이름, 급여, 급여순위 from(select employee_id 직원ID, last_name 이름, salary 급여, rank() over(order by salary desc) 급여순위 from employees)where 급여순위 between ? and ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1, beginRow);
	rankStmt.setInt(2, endRow);
	ResultSet rs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> rankList = new ArrayList<>();
	while(rs.next()){
		HashMap<String,Object> r = new HashMap<String, Object>();
		r.put("직원ID",rs.getInt("직원ID"));
		r.put("이름",rs.getString("이름"));
		r.put("급여",rs.getInt("급여"));
		r.put("급여순위",rs.getInt("급여순위"));
		rankList.add(r);
	}
	System.out.println(rankList);
	System.out.println(rankList.size()+ "<-rankList.size");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>rankFunctionEmpList</title>
<style>
a:link, a:visited {color: black; text-decoration: none;}
a:hover{color: orange;}
</style>
</head>
<body>
	<table border="1">
		<tr>
			<td>직원ID</td>
			<td>이름</td>
			<td>급여</td>
			<td>급여순위</td>
		</tr>
	<%
		for(HashMap<String,Object> r: rankList){
	%>
		<tr>
			<td><%=(Integer)r.get("직원ID")%></td>
			<td><%=(String)r.get("이름")%></td>
			<td><%=(Integer)r.get("급여")%></td>
			<td><%=(Integer)r.get("급여순위")%></td>
		</tr>
	<%
		}
	%>
	</table>
	<%
	
		// 페이지 네비게이션 페이징
		int pagePerPage = 10;
		
		
		// 마지막 페이지 페이징
		int lastPage = totalRow / rowPerPage;
		if(totalRow % rowPerPage != 0){ // 나누어 떨어지지 않으면
			lastPage = lastPage + 1;
		}
		
		// minpage
		int minPage = ((currentPage -1) / pagePerPage) * pagePerPage + 1;
		
		// maxpage
		int maxPage = minPage + (pagePerPage -1);
		if(maxPage > lastPage) {
			maxPage = lastPage;
		}
		
		if(minPage > 1) { //minpage가 1보다 클때 [이전] 페이지 출력
	%>
		<!-- 1페이지가 1이면 '이전'이 나오지 않아야 한다 -->
		<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
			}
		
		for(int i = minPage; i<=maxPage; i=i+1) {
			if(i == currentPage){
	%>
	
			<span><%=i%></span>
			
	<%			
			}else{	
	%>
	
		<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>
	
	<%
			}
		}
		
		if(maxPage != lastPage) { // maxpage와 lastpage가 같지 않을 때 다음 출력
	%>
	
		<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
		<!-- maxPage+1을 해도 결과물은 같다 -->
		<!-- 마지막 페이지에선 다음이 없어야 한다 -->

	<%
		}
	%>
</body>
</html>