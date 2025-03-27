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
    PreparedStatement stmt = conn.prepareStatement(
    "SELECT t1.inventory_id, t1.title, t2.isRental, t2.return_date " +  // return_date 컬럼을 추가
    "FROM (SELECT i.inventory_id, f.title FROM inventory i INNER JOIN film f ON i.film_id = f.film_id) t1 " +
    "LEFT OUTER JOIN (SELECT inventory_id, rental_date, " +
                         "CASE WHEN return_date IS NULL THEN '대여불가' ELSE '대여가능' END AS isRental, return_date " +  // return_date도 추가
                         "FROM rental " +
                         "WHERE (inventory_id, rental_date) IN " +
                             "(SELECT inventory_id, MAX(rental_date) FROM rental GROUP BY inventory_id)) t2 " +
    "ON t1.inventory_id = t2.inventory_id " +
    "ORDER BY t1.inventory_id ASC " +
    "LIMIT ?, ?"
	);

    stmt.setInt(1, startRow);
    stmt.setInt(2, rowPerPage);

    // 쿼리 실행
    ResultSet rs = stmt.executeQuery();

    ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("inventoryId", rs.getInt("inventory_id"));
        map.put("title", rs.getString("title"));
        map.put("isRental", rs.getString("isRental"));
        map.put("returnDate", rs.getString("return_date"));
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
    <h2>Film List</h2>
    <table border="1">
        <tr>
            <th>Inventory ID</th>
            <th>Title</th>
            <th>Rental Status</th>
            <th>Rental Link</th>
        </tr>
<%
    // 영화 목록 출력
    for (HashMap<String, Object> map : list) {
%>
        <tr>
            <td><%= map.get("inventoryId") %></td>
            <td><%= map.get("title") %></td>
            <td><%= map.get("isRental") %></td>
            <td>
            	<%
				    String returnDate = (String) map.get("returnDate");
				
				    // returnDate가 null인 경우를 체크
				    if (returnDate != null && !returnDate.equals("대여불가")) { 
				%>
				        <a href="/sakila/d0327/inventoryList.jsp">대여</a>
				<%
				    }
				%>
            </td>
        </tr>
<%
    }
%>
    </table>

    <%-- 페이지네이션 --%>
    <div>
        
            
            <% if (currentPage > 1) { %>
                <a href="?currentPage=1">[처음]</a>
            <% } %>

            
            <% if (currentPage > 1) { %>
                <a href="?currentPage=<%= currentPage - 1 %>">이전</a>
            <% } %>

            
            <% if (currentPage < totalPages) { %>
                <a href="?currentPage=<%= currentPage + 1 %>">다음</a>
            <% } %>

            
            <% if (currentPage < totalPages) { %>
                <a href="?currentPage=<%= totalPages %>">[마지막]</a>
            <% } %>
        
    </div>

</body>
</html>
