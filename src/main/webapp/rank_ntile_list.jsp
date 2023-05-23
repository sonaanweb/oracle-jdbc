<%@page import="oracle.net.aso.r"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	/* 1. salary 내림차순 정렬, n개의 그룹으로 나누어 어느 그룹에 속하는지 ntile(n)
	select first_name, salary, ntile(10) over(order by salary desc)from employees; 
	ntile(10)=10등분 -- 10구간으로 나눌것 */

	// DB연동  ------------------------------------------------------------------
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	// System.out.println(conn+"<---rank ntile list conn");
	
	// 페이징 (1) 요청값 검사 ------------------------------------------------------------------
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	// DB연결 후 페이징 (2) -------------------------------------------------------------------
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
	
	// (1) Ntile(10) 쿼리 - executeQuery + 리스트 ArrayList 사용 -------------------------------
	/*"select 번호, 이름, 급여, 등급 from
	(select rownum 번호, 이름, 급여, 등급 from
	(select first_name 이름, salary 급여, ntile(10)over(order by salary desc)등급 from employees))
	where 번호 between ? and ?";*/
	String ntileSql = "select 번호, 이름, 급여, 등급 from(select rownum 번호, 이름, 급여, 등급 from(select first_name 이름, salary 급여, ntile(10) over(order by salary desc)등급 from employees)) where 번호 between ? and ?";
	PreparedStatement ntileStmt = conn.prepareStatement(ntileSql);
	ntileStmt.setInt(1, beginRow);
	ntileStmt.setInt(2, endRow);
	ResultSet ntileRs =  ntileStmt.executeQuery();
	// System.out.println(ntileStmt+"<---rank ntile list stmt");
	
	ArrayList<HashMap<String,Object>> ntileList = new ArrayList<>();
	while(ntileRs.next()){
		HashMap<String,Object> n = new HashMap<>();
		n.put("번호",ntileRs.getInt("번호"));
		n.put("이름",ntileRs.getString("이름"));
		n.put("급여",ntileRs.getInt("급여"));
		n.put("등급",ntileRs.getInt("등급"));
		ntileList.add(n);
	}	
	System.out.println(ntileList);
	System.out.println(ntileList.size()+ "<-list.size");
	
	// (2) RANK 쿼리 - excuteQuery + 리스트 ArrayList 사용 --------------------------------------
	// rank는 동일한 값일 시 중복 순위를 부여하고, 이후 순위는 중복 순위 개수만큼 건너 뛰고 반환한다.
	/*
	"select 번호, 사원이름, 급여, 순위
	from (select rownum 번호, 사원이름, 급여, 순위 from
	(select first_name 사원이름, salary 급여, rank() over(order by salary) 순위 from employees))
	where 번호 between ? and ?";
	*/
	String rankSql = "select 번호, 이름, 급여, 순위 from (select rownum 번호, 이름, 급여, 순위 from(select first_name 이름, salary 급여, rank() over(order by salary desc) 순위 from employees))where 번호 between ? and ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1,beginRow);
	rankStmt.setInt(2,endRow);
	ResultSet rankRs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> rankList = new ArrayList<>();
	while(rankRs.next()){
		HashMap<String,Object> r = new HashMap<>();
		r.put("번호",rankRs.getInt("번호"));
		r.put("이름",rankRs.getString("이름"));
		r.put("급여",rankRs.getInt("급여"));
		r.put("순위",rankRs.getInt("순위"));
		rankList.add(r);
	}	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>rank ntile List</title>
<style>
a:link, a:visited {color: black; text-decoration: none;}
a:hover{color: orange;}
</style>
</head>
<body>
	<h1>Ntile_list</h1>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>급여</td>
			<td>등급</td>
		</tr>
	<%
		for(HashMap<String,Object> n: ntileList){
	%>
		<tr>
			<td><%=(Integer)n.get("번호")%></td>
			<td><%=(String)n.get("이름")%></td>
			<td><%=(Integer)n.get("급여")%></td>
			<td><%=(Integer)n.get("등급")%></td>
		</tr>
	<%
		}
	%>
	</table>
	<hr>
	<h1>Rank_list</h1>
	<table>
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>급여</td>
			<td>순위</td>
		</tr>
	<%
		for(HashMap<String,Object> r : rankList) {
	%>
		<tr>
			<td><%=(Integer)r.get("번호")%></td>
			<td><%=(String)r.get("이름")%></td>
			<td><%=(Integer)r.get("급여")%></td>
			<td><%=(Integer)r.get("순위")%></td>
		</tr>
	<%
		}
	%>
	</table>
	<!-- 페이징 작업 : 결과값을 보여주는 거라 전체 통합 한번만 -->
	<br>
	<%
		if(minPage>1){ //하단 페이지 가장 작은 수가 1보다 클 때 (이전)링크 표시
	%>
		<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
		}
		for(int i = minPage; i<=maxPage; i=i+1) {
		if(i == currentPage){ //현재 페이지 표시
	%>
		<span><%=i%></span>
	<%
		} else {
	%>
		<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>
	<%
			}
		}
		if(maxPage != lastPage) {// maxpage와 lastpage가 같지 않을 때 (다음)링크 출력
	%>
		<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
</body>
</html>