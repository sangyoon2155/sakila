<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
</head>
<body>
	<h1>비밀번호 수정</h1>
	<form action="/sakila/updatePasswordAction.jsp">
		<table border="1">
			<tr>
				<th>StaffId</th>
				<td><input type="number" name="staffId"></td>
			</tr>
			<tr>
				<th>Password</th>
				<td><input type="password" name="password"></td>
			</tr>
			<tr>
				<th>NewPassword</th>
				<td><input type="password" name="newPassword"></td>
			</tr>
		</table>
		<button type="submit">수정</button>
	</form>
</body>
</html>