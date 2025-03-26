<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // 배우 이름 가져오기
    String name = request.getParameter("name");

    // 현재 페이지 번호 가져오기
    int currentPage = 1;
    if (request.getParameter("currentPage") != null) {
        currentPage = Integer.parseInt(request.getParameter("currentPage"));
    }

    // 한 페이지당 보여줄 영화 수
    int rowPerPage = 10;
    int startRow = (currentPage - 1) * rowPerPage;

    // MySQL 드라이버 로드 및 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");

    // 전체 영화 수 계산
    PreparedStatement countStmt = conn.prepareStatement(
        "SELECT COUNT(f.film_id) AS totalFilms " +
        "FROM film f " +
        "JOIN film_actor fa ON f.film_id = fa.film_id " +
        "JOIN actor a ON fa.actor_id = a.actor_id " +
        "WHERE CONCAT(a.first_name, ' ', a.last_name) = ?");
    countStmt.setString(1, name);  // 배우 이름 필터링
    ResultSet countRs = countStmt.executeQuery();
    countRs.next();
    int totalFilms = countRs.getInt("totalFilms");

    // 전체 페이지 수 계산
    int totalPages = (int) Math.ceil(totalFilms / (double) rowPerPage);

    // 영화 목록 쿼리 준비
    PreparedStatement stmt = conn.prepareStatement(
        "SELECT f.film_id, f.title AS film_title, f.release_year AS release_year, f.length AS length, f.rating AS rating " +
        "FROM film f " +
        "JOIN film_actor fa ON f.film_id = fa.film_id " +
        "JOIN actor a ON fa.actor_id = a.actor_id " +
        "WHERE CONCAT(a.first_name, ' ', a.last_name) = ? " +
        "LIMIT ?, ?");
    stmt.setString(1, name); // 배우 이름 필터링
    stmt.setInt(2, startRow); // 페이징 시작 위치
    stmt.setInt(3, rowPerPage); // 한 페이지당 영화 수

    // 쿼리 실행
    ResultSet rs = stmt.executeQuery();

    // 결과 리스트 저장
    ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("filmId", rs.getInt("film_id"));
        map.put("title", rs.getString("film_title"));
        map.put("releaseYear", rs.getInt("release_year"));
        map.put("length", rs.getInt("length"));
        map.put("rating", rs.getString("rating"));
        list.add(map);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Actor Films</title>
</head>
<body>
    <h2>Actor Films</h2>
    <table border="1">
        <tr>
            <th>Title</th>
            <th>Release Year</th>
            <th>Length</th>
            <th>Rating</th>
        </tr>
<%
    // 영화 정보 출력
    for (HashMap<String, Object> map : list) { 
%>
        <tr>
            <td>
                <a href="filmOne.jsp?filmId=<%= map.get("filmId") %>">
                    <%= map.get("title") %>
                </a>
            </td>
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
        <a href="actorOne.jsp?name=<%= name %>&currentPage=1">[처음]</a>

        <!-- 이전 페이지 버튼 -->
        <a href="actorOne.jsp?name=<%= name %>&currentPage=<%= (currentPage - 1 > 0) ? currentPage - 1 : 1 %>">이전</a>

        <!-- 다음 페이지 버튼 -->
        <a href="actorOne.jsp?name=<%= name %>&currentPage=<%= (currentPage + 1 <= totalPages) ? currentPage + 1 : totalPages %>">다음</a>

        <!-- 마지막 페이지 버튼 -->
        <a href="actorOne.jsp?name=<%= name %>&currentPage=<%= totalPages %>">[마지막]</a>
    </div>
</body>
</html>
