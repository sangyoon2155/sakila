<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // URL 파라미터로 전달된 filmId와 currentPage 가져오기
    String filmId = request.getParameter("filmId");

    // currentPage 파라미터가 null이면 기본값 1로 설정
    int currentPage = 1;
    if (request.getParameter("currentPage") != null) {
        currentPage = Integer.parseInt(request.getParameter("currentPage"));
    }

    // 페이징 설정
    int rowPerPage = 10;
    int startRow = (currentPage - 1) * rowPerPage;

    // 1) 드라이버 로딩
    Class.forName("com.mysql.cj.jdbc.Driver");

    // 2) 접속(mysql주소, mysql계정, mysql암호)
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");

    // 전체 영화 수 구하기
    PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) AS totalFilms FROM film");
    ResultSet countRs = countStmt.executeQuery();
    countRs.next();
    int totalFilms = countRs.getInt("totalFilms");

    // 전체 페이지 수 계산
    int totalPages = (int) Math.ceil(totalFilms / (double) rowPerPage);

    // 3) 영화 상세 정보 쿼리 준비 -> PreparedStatement
    PreparedStatement stmt = conn.prepareStatement(
        "SELECT f.title AS title, " +
        "CONCAT(a.first_name, ' ', a.last_name) AS name, " +
        "f.description AS description, " +
        "f.release_year AS releaseYear, " +
        "f.length AS length, " +
        "f.rating AS rating " +
        "FROM film f " +
        "JOIN film_actor fa ON f.film_id = fa.film_id " +
        "JOIN actor a ON fa.actor_id = a.actor_id " +
        "WHERE f.film_id = ? " +
        "ORDER BY a.last_name, a.first_name"
    );

    // 4) 쿼리 파라미터 설정
    stmt.setInt(1, Integer.parseInt(filmId)); // 영화 ID로 필터링

    // 5) 쿼리 실행 및 결과 처리
    ResultSet rs = stmt.executeQuery();

    ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("title", rs.getString("title"));
        map.put("name", rs.getString("name"));
        map.put("description", rs.getString("description"));
        map.put("releaseYear", rs.getInt("releaseYear"));
        map.put("length", rs.getInt("length"));
        map.put("rating", rs.getString("rating"));
        list.add(map);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Film Details</title>
</head>
<body>
    <h2>Film Details</h2>
    <table border="1">
        <tr>
            <th>Title</th>
            <th>Name</th>
            <th>Description</th>
            <th>Release Year</th>
            <th>Length</th>
            <th>Rating</th>
        </tr>
<%
    // 영화 정보 출력
    for (HashMap<String, Object> map : list) {
%>
        <tr>
            <td><%= map.get("title") %></td>
            <td>
                <a href="actorOne.jsp?name=<%= map.get("name") %>">
                    <%= map.get("name") %>
                </a>
            </td>
            <td><%= map.get("description") %></td>
            <td><%= map.get("releaseYear") %></td>
            <td><%= map.get("length") %></td>
            <td><%= map.get("rating") %></td>
        </tr>
<%
    }
%>
    </table>

    <!-- 페이지 네비게이션 -->
    <div>
        <!-- 처음 페이지 버튼 -->
        <a href="filmOne.jsp?filmId=<%= filmId %>&currentPage=1">[처음]</a>

        <!-- 이전 페이지 버튼 -->
        <a href="filmOne.jsp?filmId=<%= filmId %>&currentPage=<%= currentPage - 1 > 1 ? currentPage - 1 : 1 %>">이전</a>

        <!-- 다음 페이지 버튼 -->
        <a href="filmOne.jsp?filmId=<%= filmId %>&currentPage=<%= currentPage + 1 < totalPages ? currentPage + 1 : totalPages %>">다음</a>

        <!-- 마지막 페이지 버튼 -->
        <a href="filmOne.jsp?filmId=<%= filmId %>&currentPage=<%= totalPages %>">[마지막]</a>
    </div>

</body>
</html>
