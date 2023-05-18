<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*"%>
<%@ page import ="java.util.*"%>
<%
	/*select employee_id, last_name, salary, round(avg(salary) over()) 전체급여평균,
	sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees;
	
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
	
	int rowPerPage = 10; // 한 페이지당 열 개수
	int beginRow = (currentPage-1) * rowPerPage + 1; // beginrow 1부터 시작
	int endRow = beginRow + (rowPerPage - 1); // 보여지는 각 페이지중 마지막 행
	if(endRow > totalRow) { 
		endRow = totalRow;
	}
	
	//------- 페이징 쿼리 + 번호 추가
	String Sql = "select 번호, 직원ID, 이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 from(select rownum 번호, employee_id 직원ID, last_name 이름, salary 급여, round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees) where 번호 between ? and ?";
	PreparedStatement Stmt = conn.prepareStatement(Sql);
	Stmt.setInt(1, beginRow);
	Stmt.setInt(2, endRow);
	ResultSet rs = Stmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> list
			= new ArrayList<HashMap<String,Object>>();
	while(rs.next()){
		HashMap<String,Object> m = new HashMap<String, Object>();
		m.put("번호",rs.getInt("번호"));
		m.put("직원ID",rs.getInt("직원ID"));
		m.put("이름",rs.getString("이름"));
		m.put("급여",rs.getInt("급여"));
		m.put("전체급여평균",rs.getInt("전체급여평균"));
		m.put("전체급여합계",rs.getInt("전체급여합계"));
		m.put("전체사원수",rs.getInt("전체사원수"));
		list.add(m);
	}
	System.out.println(list);
	System.out.println(list.size()+ "<-list.size");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>windowsFunctionEmpList</title>
<style>
a:link, a:visited {color: black; text-decoration: none;}
a:hover{color: orange;}
</style>
</head>
<body>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>직원ID</td>
			<td>이름</td>
			<td>급여</td>
			<td>전체급여평균</td>
			<td>전체급여합계</td>
			<td>전체사원수</td>
		</tr>
		
	<%
		for(HashMap<String,Object> m : list){
	%>
		<tr>
			<td><%=(Integer)m.get("번호")%></td>
			<td><%=(Integer)m.get("직원ID")%></td>
			<td><%=(String)m.get("이름")%></td>
			<td><%=(Integer)m.get("급여")%></td>
			<td><%=(Integer)m.get("전체급여평균")%></td>
			<td><%=(Integer)m.get("전체급여합계")%></td>
			<td><%=(Integer)m.get("전체사원수")%></td>
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
		<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%
			}
		
		for(int i = minPage; i<=maxPage; i=i+1) {
			if(i == currentPage){
	%>
	
			<span><%=i%></span>
			
	<%			
			}else{	
	%>
	
		<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>
	
	<%
			}
		}
		
		if(maxPage != lastPage) { // maxpage와 lastpage가 같지 않을 때 다음 출력
	%>
	
		<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
		<!-- maxPage+1을 해도 결과물은 같다 -->
		<!-- 마지막 페이지에선 다음이 없어야 한다 -->

	<%
		}
	%>
	<!-- 커밋 확인용 주석 -->
</body>
</html>