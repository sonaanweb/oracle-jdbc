<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%

	/* -- null 관련 함수 -> null을 다른값으로 치환
	-- nvl(), nvl2(), nullif(), coalesce()
	select 20+null from emp; -- 숫자+null -> null이 된다 -> null을 숫자값을 치환이 필요하다*/
	
	// DB연동 
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	// 1) select 이름, nvl(일분기, 0) from 실적 쿼리
	// 일분기에 값이 있으면 일분기 값 출력, 없으면 0으로 출력
	String nvlSql = "select 이름, nvl(일분기,0) 일분기 from 실적";
	PreparedStatement nvlStmt = conn.prepareStatement(nvlSql);
	ResultSet nvlRs = nvlStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> nvlList = new ArrayList<>();
	while(nvlRs.next()){
		HashMap<String,Object> m = new HashMap<>(); // 자동으로 동일하게 들어옴
		m.put("이름", nvlRs.getString("이름"));
		m.put("일분기", nvlRs.getString("일분기"));
		nvlList.add(m);
	}
	System.out.println(nvlList + " <--- nvlList");
	
	// 2) select 이름, nvl2(일분기, 'success', 'fail') from 실적;
	// 일분기에 값이 null이 아니면 success 출력, 일분기 값이 null이면 fail 출력
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') 일분기 from 실적";
	PreparedStatement nvl2Stmt = conn.prepareStatement(nvl2Sql);
	ResultSet nvl2Rs = nvl2Stmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> nvl2List = new ArrayList<>();
	while(nvl2Rs.next()){
		HashMap<String,Object> m = new HashMap<>(); // 자동으로 동일하게 들어옴
		m.put("이름", nvl2Rs.getString("이름"));
		m.put("일분기", nvl2Rs.getString("일분기"));
		nvl2List.add(m);
	}
	System.out.println(nvl2List + " <--- nvl2List");
	
	// 3) select 이름, nullif(사분기, 100) from 실적;
	// 사분기의 값이 100이면 null
	String nullifSql = "select 이름, nullif(사분기,100) 사분기 from 실적";
	PreparedStatement nvlifStmt = conn.prepareStatement(nullifSql);
	ResultSet nullifRs = nvlifStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> nullifList = new ArrayList<>();
	while(nullifRs.next()){
		HashMap<String,Object> m = new HashMap<>(); // 자동으로 동일하게 들어옴
		m.put("이름", nullifRs.getString("이름"));
		m.put("사분기", nullifRs.getString("사분기"));
		nullifList.add(m);
	}
	System.out.println(nullifList + " <--- nullifList");
	
	// 4) select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적;
	// 일분기 ~ 사분기중 null이 아닌 첫번째 분기 값 반환
	String coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) 첫실적 from 실적";
	PreparedStatement coalesceStmt = conn.prepareStatement(coalesceSql);
	ResultSet coalesceRs = coalesceStmt.executeQuery();
	
	ArrayList<HashMap<String,Object>> coalesceList = new ArrayList<>();
	while(coalesceRs.next()){
		HashMap<String,Object> m = new HashMap<>(); // 자동으로 동일하게 들어옴
		m.put("이름", coalesceRs.getString("이름"));
		m.put("첫실적", coalesceRs.getString("첫실적"));
		coalesceList.add(m);
	}
	System.out.println(coalesceList + " <--- coalesceList");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>null function</title>
</head>
<body>
<div>
	<h2>nvl</h2>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>일분기</td>
		</tr>
		<%
			for(HashMap<String,Object> m : nvlList){
		%>
		<tr>
			<td><%=(String)m.get("이름")%></td>
			<td><%=(String)m.get("일분기")%></td>
		</tr>
		<%
			}
		%>
	</table>
	<hr> <!-- 선 -->
	<h2>nvl2</h2>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>일분기</td>
		</tr>
		<%
			for(HashMap<String,Object> m : nvl2List){
		%>
		<tr>
			<td><%=(String)m.get("이름")%></td>
			<td><%=(String)m.get("일분기")%></td>
		</tr>
		<%
			}
		%>
	</table>
	<hr>
	<h2>nullif</h2>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>사분기</td>
		</tr>
		<%
			for(HashMap<String,Object> m : nullifList){
		%>
		<tr>
			<td><%=(String)m.get("이름")%></td>
			<td><%=(String)m.get("사분기")%></td>
		</tr>
		<%
			}
		%>
	</table>
	<hr> <!-- 선 -->
	<h2>coalesceList</h2>
	<table border="1">
		<tr>
			<td>이름</td>
			<td>첫실적</td>
		</tr>
		<%
			for(HashMap<String,Object> m : coalesceList){
		%>
		<tr>
			<td><%=(String)m.get("이름")%></td>
			<td><%=(String)m.get("첫실적")%></td>
		</tr>
		<%
			}
		%>
	</table>
</div>
</body>
</html>