<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	// 로그인 되었는지 아닌지?
	Integer staffId = (Integer)(session.getAttribute("loginStaff"));
			
	if(staffId != null) { // 로그인 상태라면
		response.sendRedirect("/sakila/index.jsp");
		return;
	}

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
</head>
<body>
	<h1>Staff Login</h1>
	<form action="/sakila/loginAction.jsp" method=post"> 
	<!--
		 a태그랑 동일한 방식 : loginAction.jsp?number= & password=
		 매개값이 노출, 주소창의 문자열형태로 넘어감 <- 길이가 제한	 
		 데이터값을 매개값으로 다른 페이지로 전송
		 1) a태그 : get
		 2) form태그의 method 속성	 
	-->
		<table border="1">
			<tr>
				<th>staffId</th>
				<td><input type="number" name="staffId">
			</tr>
			<tr>
				<th>password</th>
				<td><input type="password" name="password">
			</tr>
		</table>
		<button type="submit">로그인</button>
	</form>
</body>
</html>
