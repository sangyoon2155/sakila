<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<%
	// controller layer : staffId, password
	int staffId = Integer.parseInt(request.getParameter("staffId"));
	String password = request.getParameter("password");
	String newPassword = request.getParameter("newPassword");
	
	System.out.println("staffId: "+ staffId);
	System.out.println("password: "+ password);
	System.out.println("newPassword: "+ newPassword);
	
	Connection conn = null;
	PreparedStatement stmt = null;
	String sql = "UPDATE staff SET PASSWORD = ? WHERE staff_id = ? AND PASSWORD = ?";
	Class.forName("com.mysql.cj.jdbc.Driver");
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila","root","java1234");
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, newPassword);
	stmt.setInt(2, staffId);
	stmt.setString(3, password);
	
	int rowsAffected = stmt.executeUpdate();  // executeUpdate()는 업데이트된 행 수를 반환

    // 비밀번호 변경 성공 여부 확인
    if (rowsAffected > 0) {
        // 비밀번호가 성공적으로 변경된 경우
        response.sendRedirect("/sakila/index.jsp?success=password_updated");
        System.out.println("수정 성공");
        session.invalidate();
        
    } else {
        // 비밀번호가 일치하지 않거나 staffId가 없는 경우
        response.sendRedirect("/sakila/updatePasswordForm.jsp?error=invalid_credentials");
        System.out.println("수정 실패");
    }
	
%>
