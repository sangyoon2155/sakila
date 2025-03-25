<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String searchStr = request.getParameter("searchWord");
    String storeIdStr = request.getParameter("storeId");
    int storeId = 0;

    
    if (storeIdStr != null && !storeIdStr.isEmpty()) {
        storeId = Integer.parseInt(storeIdStr);
    }

    Connection conn = null;
    PreparedStatement stmt1 = null;
    ResultSet rs1 = null;

    PreparedStatement stmt2 = null;
    ResultSet rs2 = null;

    // JDBC 드라이버 로드 및 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    System.out.println("드라이버 로딩 성공!");
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
    
    // 전체 데이터 개수를 계산하는 쿼리
    String sql1 = "SELECT count(*) "
                 + "FROM ("
                 + "SELECT r.rental_id  rentalId, "
                 + "f.title  filmTitle, "
                 + "i.inventory_id  inventoryId, "
                 + "CONCAT(c.first_name, ' ', c.last_name)  name, "
                 + "r.rental_date  rentalDate, "
                 + "r.return_date  returnDate "
                 + "FROM rental r "
                 + "INNER JOIN customer c ON r.customer_id = c.customer_id "
                 + "INNER JOIN inventory i ON r.inventory_id = i.inventory_id "
                 + "INNER JOIN film f ON i.film_id = f.film_id ";
                 
    if (storeId != 0) {
        sql1 += "WHERE i.store_id = ? "; // 지점이 선택된 경우
    }
    
    if (searchStr != null && !searchStr.trim().isEmpty()) {
        sql1 += (storeId != 0 ? " AND " : "WHERE ") + "f.title LIKE ? "; // 검색어가 있는 경우
    }

    sql1 += ") a";

   
    stmt1 = conn.prepareStatement(sql1);

    int paramIndex = 1;

    if (storeId != 0) {
        stmt1.setInt(paramIndex++, storeId);
    }
    
    if (searchStr != null && !searchStr.trim().isEmpty()) {
        stmt1.setString(paramIndex++, "%" + searchStr + "%");
    }

    rs1 = stmt1.executeQuery();
    rs1.next();
    int totalCnt = rs1.getInt(1);
    int rowPerPage = 10; // 페이지 당 데이터 수
    int currentPage = 1; // 기본적으로 1페이지로 설정

    if (request.getParameter("currentPage") != null) {
        currentPage = Integer.parseInt(request.getParameter("currentPage"));
    }

    int startRow = (currentPage - 1) * rowPerPage;

    // 마지막 페이지 계산
    int lastPage = totalCnt / rowPerPage;
    if (totalCnt % rowPerPage != 0) {
        lastPage = lastPage + 1;
    }

    // 검색어와 지점 필터를 포함한 영화 데이터를 가져오는 쿼리
    String sql2 = "SELECT r.rental_id  rentalId, f.title  filmTitle, i.inventory_id  inventoryId, "
                 + "CONCAT(c.first_name, ' ', c.last_name)  name, r.rental_date  rentalDate, r.return_date  returnDate "
                 + "FROM rental r "
                 + "INNER JOIN customer c ON r.customer_id = c.customer_id "
                 + "INNER JOIN inventory i ON r.inventory_id = i.inventory_id "
                 + "INNER JOIN film f ON i.film_id = f.film_id ";
    
    if (storeId != 0) {
        sql2 += "WHERE i.store_id = ? ";
    }
    
    if (searchStr != null && !searchStr.trim().isEmpty()) {
        sql2 += (storeId != 0 ? " AND " : "WHERE ") + "f.title LIKE ? ";
    }

    sql2 += "ORDER BY r.rental_id ASC LIMIT ?, ?";
    
    stmt2 = conn.prepareStatement(sql2);

    paramIndex = 1;
    
    if (storeId != 0) {
        stmt2.setInt(paramIndex++, storeId);
    }

    if (searchStr != null && !searchStr.trim().isEmpty()) {
        stmt2.setString(paramIndex++, "%" + searchStr + "%");
    }

    stmt2.setInt(paramIndex++, startRow);
    stmt2.setInt(paramIndex++, rowPerPage);

    rs2 = stmt2.executeQuery();
    
    ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
    while (rs2.next()) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("rentalId", rs2.getInt("rentalId"));
        map.put("filmTitle", rs2.getString("filmTitle"));
        map.put("inventoryId", rs2.getInt("inventoryId"));
        map.put("name", rs2.getString("name"));
        map.put("rentalDate", rs2.getString("rentalDate")); 
        map.put("returnDate", rs2.getString("returnDate"));
        list.add(map);
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rental List</title>
</head>
<body>
    <h1>Rental List</h1>
    
    <table border="1">
        <tr>
            <th>rentalId</th>
            <th>filmTitle</th>
            <th>inventoryId</th>
            <th>name(customerId)</th>
            <th>rentalDate</th>
            <th>returnDate</th>
        </tr>
        <% for (HashMap<String, Object> map : list) { %>
            <tr>
                <td><%= map.get("rentalId") %></td>
                <td><%= map.get("filmTitle") %></td>
                <td><%= map.get("inventoryId") %></td>
                <td><%= map.get("name") %></td>
                <td><%= map.get("rentalDate") %></td>
                <td><%= map.get("returnDate") %></td>
            </tr>
        <% } %>
    </table>
	<form action="/sakila/d0325/rentalList.jsp">
        store :
        <select name="storeId">
            <option value="0" <%= storeId == 0 ? "selected" : "" %>>전체</option>
            <option value="1" <%= storeId == 1 ? "selected" : "" %>>1지점</option>
            <option value="2" <%= storeId == 2 ? "selected" : "" %>>2지점</option>
        </select>
        <input type="text" name="searchWord" value="<%= searchStr != null ? searchStr : "" %>">
        <button type="submit">검색</button>
    </form>
    <a href="/sakila/d0325/rentalList.jsp?currentPage=1<%= searchStr != null ? "&searchWord=" + searchStr : "" %>&storeId=<%= storeId %>">[처음]</a>
    <% if (currentPage > 1) { %>
        <a href="/sakila/d0325/rentalList.jsp?currentPage=<%= currentPage - 1 %><%= searchStr != null ? "&searchWord=" + searchStr : "" %>&storeId=<%= storeId %>">[이전]</a>
    <% } %>
    <%= currentPage %>
    <% if (currentPage < lastPage) { %>
        <a href="/sakila/d0325/rentalList.jsp?currentPage=<%= currentPage + 1 %><%= searchStr != null ? "&searchWord=" + searchStr : "" %>&storeId=<%= storeId %>">[다음]</a>
    <% } %>
    <a href="/sakila/d0325/rentalList.jsp?currentPage=<%= lastPage %><%= searchStr != null ? "&searchWord=" + searchStr : "" %>&storeId=<%= storeId %>">[마지막]</a>
</body>
</html>
