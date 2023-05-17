<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%

	/*
	1)select department_id, job_id, count(*) from employees
	group by department_id, job_id; -- 20행
	
	2)select department_id, job_id, count(*) from employees
	group by rollup(department_id, job_id); -- 33행 / rollup은 첫번째 값 집계
	
	3)select department_id, job_id, count(*) from employees
	group by cube(department_id, job_id); -- cube 모든 열 조합의 집계그룹 만듦
	*/

	// DB연동 
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	// 1) group by 쿼리 -- select = executeQuery
	// 부서명, 직무 ID, 총 인원수 테이블 출력
	String sql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY department_id, job_id";
	PreparedStatement stmt = conn.prepareStatement(sql);
	/*System.out.println(stmt);*/
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> list1
			= new ArrayList<HashMap<String,Object>>();
	while(rs.next()){
		HashMap<String,Object> m1 = new HashMap<String, Object>();
		m1.put("부서ID",rs.getInt("department_id"));
		m1.put("직급ID",rs.getString("job_id"));
		m1.put("인원",rs.getInt("count(*)"));
		list1.add(m1);
	}
	
	// 2) group by rollup 쿼리 -- select = "
	String sql2 = "select department_id, job_id, count(*) from employees group by rollup(department_id, job_id)";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	
	ArrayList<HashMap<String,Object>> list2
		= new ArrayList<HashMap<String,Object>>();
	while(rs2.next()){
	HashMap<String,Object> m2 = new HashMap<String, Object>();
	m2.put("부서ID",rs2.getInt("department_id"));
	m2.put("직급ID",rs2.getString("job_id"));
	m2.put("인원",rs2.getInt("count(*)"));
	list2.add(m2);
	}
	
	// 3) group by cube 쿼리 -- select = "
	String sql3 = "select department_id, job_id, count(*) from employees group by cube(department_id, job_id)";
	PreparedStatement stmt3 = conn.prepareStatement(sql3);
	ResultSet rs3 = stmt3.executeQuery();
	ArrayList<HashMap<String,Object>> list3
		= new ArrayList<HashMap<String,Object>>();
	while(rs3.next()){
	HashMap<String,Object> m3 = new HashMap<String, Object>();
	m3.put("부서ID",rs3.getInt("department_id"));
	m3.put("직급ID",rs3.getString("job_id"));
	m3.put("인원",rs3.getInt("count(*)"));
	list3.add(m3);

}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h2>group by</h2>
	<table>
		<tr>
			<td>부서명</td>
			<td>직무ID</td>
			<td>인원수</td>
		</tr>
	<%
         for(HashMap<String, Object> m1 : list1) {
    %>
		<tr>
			<td><%=(Integer)(m1.get("부서ID"))%></td>
			<td><%=m1.get("직급ID")%></td> <!-- string 그대로 -->
			<td><%=(Integer)(m1.get("인원"))%></td>
		</tr>
	<%
         }
	%>
	</table>
	<hr>
	<h2>group by rollup</h2>
	<table>
		<tr>
			<td>부서명</td>
			<td>직무ID</td>
			<td>인원수</td>
		</tr>
	<%
         for(HashMap<String, Object> m2 : list2) {
    %>
		<tr>
			<td><%=(Integer)(m2.get("부서ID"))%></td>
			<td><%=m2.get("직급ID")%></td> <!-- string 그대로 -->
			<td><%=(Integer)(m2.get("인원"))%></td>
		</tr>
	<%
         }
	%>
	</table>
	<hr>
	<h2>group by cube</h2>
	<table>
		<tr>
			<td>부서명</td>
			<td>직무ID</td>
			<td>인원수</td>
		</tr>
	<%
         for(HashMap<String, Object> m3 : list3) {
    %>
		<tr>
			<td><%=(Integer)(m3.get("부서ID"))%></td>
			<td><%=m3.get("직급ID")%></td> <!-- string 그대로 -->
			<td><%=(Integer)(m3.get("인원"))%></td>
		</tr>
	<%
         }
	%>
	</table>
</body>
</html>