<%@page import="javax.naming.spi.DirStateFactory.Result"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%
	/*
	1. select e.employee_id, e.first_name
	from employees e -- 결과셋 ()
	where exists (select * from departments d -- 서브쿼리 계산셋: d.id가 e.id에 있는 사람을 찾아라 
	* = rowid (count/exists) 결과셋 있으면 추출
	where d.department_id = e.department_id);

	2.not exists ( 전체에서 빼는 것 보다는 not exists를 써서 해당하지 않는 사람을 계산하는 게 낫다 )
	select e.employee_id, e.first_name
	from employees e -- 결과셋
	where not exists (select * from departments d
	where d.department_id = e.department_id);
	*/

	//DB연동  ------------------------------------------------------------------
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	// System.out.println(conn+"<---rank ntile list conn");
	
	// 페이징 (1) ------------------------------------------------------------------
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	// DB연결 후 페이징 (2) 쿼리 1 ------------------------------------------------------------------
	int totalRow = 0; // 테이블 총 행
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	
	if(totalRowRs.next()){ // 결과값
		totalRow = totalRowRs.getInt("count(*)"); // totalRowRs.getInt("count(*)")
	}
	
	int rowPerPage = 10; // 한 페이지당 열 개수
	int beginRow = (currentPage-1) * rowPerPage + 1; // beginrow 1부터 시작
	int endRow = beginRow + (rowPerPage - 1); // 보여지는 각 페이지중 마지막 행
	if(endRow > totalRow) { 
		endRow = totalRow;
	}
	
	// 페이지 네비게이션 페이징 (3) ------------------------------------------------------------------
	int pagePerPage = 10;
	
	// 마지막 페이지 페이징
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){ // 나누어 떨어지지 않으면
		lastPage = lastPage + 1;
	}
	
	// minpage (하단에 표시되는 페이지 내 가장 작은 수)
	int minPage = ((currentPage -1) / pagePerPage) * pagePerPage + 1;
	
	// maxpage (하단에 표시되는 페이지 내 가장 큰 수)
	int maxPage = minPage + (pagePerPage -1);
	if(maxPage > lastPage) {
		maxPage = lastPage;
	}
	//----------------------------------------------------------------------------------------

	
	// (1) exists 쿼리 : employee_id & department_id 둘 다 존재하는 직원리스트
	/*
	"select 번호, 아이디, 이름 from(select rownum 번호, e.employee_id 아이디, e.first_name 이름
	from employees e where exists
	(select * from departments d where d. department_id = e.department_id))
	where 번호 between ? and ?";
	*/
	String existSql = "select 번호, 아이디, 이름 from(select rownum 번호, e.employee_id 아이디, e.first_name 이름 from employees e where exists (select * from departments d where d.department_id = e.department_id))where 번호 between ? and ?";
	PreparedStatement existStmt = conn.prepareStatement(existSql);
	System.out.println(existStmt+"<---exist e stmt");
	existStmt.setInt(1, beginRow);
	existStmt.setInt(2, endRow);
	ResultSet existRs = existStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> existList = new ArrayList<>();
	while(existRs.next()){
		HashMap<String,Object> e = new HashMap<>();
		e.put("번호",existRs.getInt("번호"));
		e.put("아이디",existRs.getInt("아이디"));
		e.put("이름",existRs.getString("이름"));
		existList.add(e);
	}
	//System.out.println(existList+"<---");
	
	
	// (2) not exists 쿼리 : department_id가 존재하지 않는 직원 리스트
	/*
	
	*/
	String notExSql = "select 번호, 아이디, 이름 from(select rownum 번호, e.employee_id 아이디, e.first_name 이름 from employees e where not exists (select * from departments d where d.department_id = e.department_id))where 번호 between ? and ?";
	PreparedStatement notExStmt = conn.prepareStatement(notExSql);
	System.out.println(notExStmt+"<---notEx stmt");
	notExStmt.setInt(1, beginRow);
	notExStmt.setInt(2, endRow);
	ResultSet notExRs = notExStmt.executeQuery();
	System.out.println(notExRs+"<---");
	
	ArrayList<HashMap<String,Object>> NotExistsList = new ArrayList<>();
	while(notExRs.next()){
		HashMap<String,Object> n = new HashMap<>();
		n.put("번호",notExRs.getInt("번호"));
		n.put("아이디",notExRs.getInt("아이디"));
		n.put("이름",notExRs.getString("이름"));
		NotExistsList.add(n);
	}
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
a:link, a:visited {color: black; text-decoration: none;}
a:hover{color: orange;}
</style>
</head>
<body>
	<h1>exists</h1>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>사원번호</td>
			<td>이름</td>
		</tr>
	<%
		for(HashMap<String,Object> e:existList) {
	%>
		<tr>
			<td><%=(Integer)e.get("번호")%></td>
			<td><%=(Integer)e.get("아이디")%></td>
			<td><%=(String)e.get("이름")%></td>
		</tr>
	<%
		}
	%>
	</table>
	
	<%
		if(minPage>1){ //하단 페이지 가장 작은 수가 1보다 클 때 (이전)링크 표시
	%>
		<a href="<%=request.getContextPath()%>/exists_not_exists_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage; i<=maxPage; i=i+1) {
		if(i == currentPage){ //현재 페이지 표시
	%>
		<span><%=i%></span>
	<%
		} else {
	%>
		<a href="<%=request.getContextPath()%>/exists_not_exists_list.jsp?currentPage=<%=i%>"><%=i%></a>
	<%
			}
		}
		if(maxPage != lastPage) {// maxpage와 lastpage가 같지 않을 때 (다음)링크 출력
	%>
		<a href="<%=request.getContextPath()%>/exists_not_exists_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
	<!-- 결과 값 두개 페이징 생략 -->
	<h1>not exists</h1>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>사원번호</td>
			<td>이름</td>
		</tr>
	<%
		for(HashMap<String,Object> n:NotExistsList) {
	%>
		<tr>
			<td><%=(Integer)n.get("번호")%></td>
			<td><%=(Integer)n.get("아이디")%></td>
			<td><%=(String)n.get("이름")%></td>
		</tr>
	<%
		}
	%>
	</table>
</body>
</html>