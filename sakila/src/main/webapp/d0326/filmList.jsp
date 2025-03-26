<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // 현재 페이지 가져오기
    int currentPage = 1;
    if (request.getParameter("currentPage") != null) {
        currentPage = Integer.parseInt(request.getParameter("currentPage"));
    }

    int rowPerPage = 10;  // 한 페이지당 표시할 영화 수
    int startRow = (currentPage - 1) * rowPerPage;

    // 드라이버 로딩
    Class.forName("com.mysql.cj.jdbc.Driver");

    // DB 연결
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");

    // 전체 영화 수 구하기 (전체 페이지 수 계산을 위해)
    PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS totalFilms FROM film");
    ResultSet countRs = countStmt.executeQuery();
    countRs.next();
    int totalFilms = countRs.getInt("totalFilms");

    // 전체 페이지 수 계산
    int totalPages = (int) Math.ceil(totalFilms / (double) rowPerPage);

    // 영화 목록 쿼리 준비
    PreparedStatement stmt = conn.prepareStatement("SELECT film_id, title FROM film ORDER BY film_id ASC LIMIT ?, ?");
    stmt.setInt(1, startRow);
    stmt.setInt(2, rowPerPage);

    // 쿼리 실행
    ResultSet rs = stmt.executeQuery();

    ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("filmId", rs.getInt("film_id"));
        map.put("title", rs.getString("title"));
        list.add(map);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Film List</title>
</head>
<body>
    <h2>영화 목록</h2>
    <table border="1">
        <tr>
            <th>filmId</th>
            <th>title</th>
        </tr>
<%
    // 영화 목록 출력
    for (HashMap<String, Object> map : list) {
%>
        <tr>
            <td><%= map.get("filmId") %></td>
            <td>
                <a href="filmOne.jsp?filmId=<%= map.get("filmId") %>">
                    <%= map.get("title") %>
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
        <a href="filmList.jsp?currentPage=1">[처음]</a>

        <!-- 이전 페이지 버튼 -->
        <a href="filmList.jsp?currentPage=<%= currentPage - 1 > 1 ? currentPage - 1 : 1 %>">이전</a>

        <!-- 다음 페이지 버튼 -->
        <a href="filmList.jsp?currentPage=<%= currentPage + 1 < totalPages ? currentPage + 1 : totalPages %>">다음</a>

        <!-- 마지막 페이지 버튼 -->
        <a href="filmList.jsp?currentPage=<%= totalPages %>">[마지막]</a>
    </div>

</body>
</html>
