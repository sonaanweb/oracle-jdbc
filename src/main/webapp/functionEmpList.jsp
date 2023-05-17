<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%

	/*
	select 번호, 이름, 이름첫글자, 연봉, 급여, 입사일, 입사년도
	from
	(select rownum 번호, last_name 이름, substr(last_name,1,1) 이름첫글자,
	salary 연봉, round(salary/12,2) 급여, hire_date 입사일, extract(year from hire_date) 입사년도
	from employees)
	where 번호 BETWEEN 1 and 10; ----- 페이징 때 '?' 들어갈 곳(숫자)
	*/
	
	// DB연동 
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	// 페이징
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage")); //"문자열"이니까 integer로 바꿔준다
	}
	
	int totalRow = 0; // 테이블 총 행
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	
	if(totalRowRs.next()){ // 결과값
		totalRow = totalRowRs.getInt(1); // totalRowRs.getInt("count(*)")
	}
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1; // beginrow 1부터 시작
	int endRow = beginRow + (rowPerPage - 1); // 보여지는 각 페이지중 마지막 행
	if(endRow > totalRow) { 
		endRow = totalRow;
	}
	
	// 페이징 (서브쿼리) 사용
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사일, 입사년도 from(select rownum 번호, last_name 이름, substr(last_name,1,1) 이름첫글자, salary 연봉, round(salary/12,2)급여, hire_date 입사일, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();

	// rs를 arraylist - hashmap 타입으로 변환
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object>m = new HashMap<String, Object>();
		m.put("번호", rs.getInt("번호"));
		m.put("이름", rs.getString("이름"));
		m.put("이름첫글자", rs.getString("이름첫글자"));
		m.put("연봉", rs.getInt("연봉"));
		m.put("급여", rs.getDouble("급여"));
		m.put("입사일", rs.getString("입사일"));
		m.put("입사년도", rs.getInt("입사년도")); // 날짜같은 경우는 String으로 받아도 된다
		list.add(m);
	}
	System.out.println(list.size()+ "<-list.size");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table border="1">
	<tr>
		<td>번호</td>
		<td>이름</td>
		<td>이름첫글자</td>
		<td>연봉</td>
		<td>급여</td>
		<td>입사일</td>
		<td>입사년도</td>
	</tr>
	<%
		for(HashMap<String, Object> m : list) {
	%>
		<tr>
			<td><%=(Integer)m.get("번호")%></td> <!-- 형변환 표시가 필수는 아니지만 연습을 위해 해주기 -->
			<td><%=(String)m.get("이름")%></td>
			<td><%=(String)m.get("이름첫글자")%></td>
			<td><%=(Integer)m.get("연봉")%></td>
			<td><%=(Double)m.get("급여")%></td>
			<td><%=(String)m.get("입사일")%></td>
			<td><%=(Integer)m.get("입사년도")%></td>
		</tr>
	<%
		}
	%>
	</table>
	
	<%
		// 페이지 네비게이션 페이징
		int pagePerPage = 10; // 하단 페이징 숫자 10개씩 보이게
		
		
	/*
		(minpage: 하단 페이징 내 가장 작은숫자, maxpage: 하단 페이징 내 가장 큰 숫자)
		
				c.p   minPage  maxPage
			--------------------------
				1  		1	~  10		
				2  		1	~  10	
				10  	1	~  10	
				
				11  	11	~	20
				12 		11	~	20
				20 	 	11	~	20
			
	위 표의 결과값이 나올 수 있는 알고리즘
	1) (cp-1) / pagePerPage * pagePerPage + 1 ---> minPage(결과값)
	2) minpage + (pagePerPage - 1) ---> maxPage
		maxpage < lastPage --> maxPage = lastPage
													*/
		
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
		
		if(minPage > 1) { //minpage가 1보다 클때 이전 페이지 출력
	%>
		<!-- 절대주소 사용 (getContextPath) -->
		<!-- 1페이지가 1이면 '이전'이 나오지 않아야 한다 -->
		<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
			}
		
		for(int i = minPage; i<=maxPage; i=i+1) {
			if(i == currentPage){
	%>
	
			<span><%=i%></span>
			
	<%			
			}else{	
	%>
	
		<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>
	
	<%
			}
		}
		
		if(maxPage != lastPage) { // maxpage와 lastpage가 같지 않을 때 다음 출력
	%>
	
		<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
		<!-- maxPage+1을 해도 결과물은 같다 -->
		<!-- 마지막 페이지에선 다음이 없어야 한다 -->

	<%
		}
	%>
</body>
</html>