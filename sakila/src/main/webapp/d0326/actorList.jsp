<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // URL 파라미터로 전달된 currentPage 가져오기
    int currentPage = 1;
    if (request.getParameter("currentPage") != null) {
        currentPage = Integer.parseInt(request.getParameter("currentPage"));
    }

    int rowPerPage = 10; // 한 페이지에 표시할 배우 수
    int startRow = (currentPage - 1) * rowPerPage;

    // 1) 드라이버 로딩
    Class.forName("com.mysql.cj.jdbc.Driver");

    // 2) DB 연결
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");

    // 전체 배우 수를 구하는 쿼리
    PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS totalActors FROM actor");
    ResultSet countRs = countStmt.executeQuery();
    countRs.next();
    int totalActors = countRs.getInt("totalActors");

    // 전체 페이지 수 계산
    int totalPages = (int) Math.ceil(totalActors / (double) rowPerPage);

    // 3) 배우 목록 쿼리
    PreparedStatement stmt = conn.prepareStatement("SELECT actor_id, CONCAT(first_name, ' ', last_name) AS name FROM actor ORDER BY actor_id ASC LIMIT ?, ?");
    
    // 쿼리 파라미터 설정
    stmt.setInt(1, startRow);
    stmt.setInt(2, rowPerPage);

    // 4) 쿼리 실행 및 결과 처리
    ResultSet rs = stmt.executeQuery();

    // 배우 목록을 저장할 리스트
    ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("actorId", rs.getInt("actor_id"));
        map.put("name", rs.getString("name"));
        list.add(map);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>actorList.jsp</title>
</head>
<body>
    <h2>Actor List</h2>
    <table border="1">
        <tr>
            <th>actorId</th>
            <th>name</th>
        </tr>
        <%
            // 배우 목록 출력
            for (HashMap<String, Object> map : list) {
        %>
        <tr>
            <td><%= map.get("actorId") %></td>
            <td>
                <a href="actorOne.jsp?name=<%= map.get("name") %>">
                    <%= map.get("name") %>
                </a>
            </td>
        </tr>
        <%
            }
        %>
    </table>

    <!-- 페이지 네비게이션 -->
    <div>
        <!-- 처음 페이지 버튼 -->
        <a href="actorList.jsp?currentPage=1">[처음]</a>

        <!-- 이전 페이지 버튼 -->
        <a href="actorList.jsp?currentPage=<%= (currentPage - 1 > 0) ? currentPage - 1 : 1 %>">이전</a>

        <!-- 다음 페이지 버튼 -->
        <a href="actorList.jsp?currentPage=<%= (currentPage + 1 <= totalPages) ? currentPage + 1 : totalPages %>">다음</a>

        <!-- 마지막 페이지 버튼 -->
        <a href="actorList.jsp?currentPage=<%= totalPages %>">[마지막]</a>
    </div>
</body>
</html>
