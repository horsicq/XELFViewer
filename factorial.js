<!DOCTYPE HTML>
<html>

<head>
	<title>
		Factorial of a number using JavaScript
	</title>
</head>

<body style = "text-align:center;">
	
	<h1 style = "color:green;" >
		GeeksForGeeks
	</h1>
	
	<p id = "GFG_UP" style =
		"font-size: 15px; font-weight: bold;">
	</p>
		
	<button onclick = "GFG_Fun()">
		Click Here
	</button>
	
	<p id = "GFG_DOWN" style =
		"color:green; font-size: 20px; font-weight: bold;">
	</p>
		
	<script>
		var up = document.getElementById('GFG_UP');
		var down = document.getElementById('GFG_DOWN');
		var n = 5;
		
		up.innerHTML = "Click on the button to calculate"
				+ " the factorial of n.<br>n = " + n;
		
		function Factorial(n) {
			var ans=1;
			
			for (var i = 2; i <= n; i++)
				ans = ans * i;
			return ans;
		}
		
		function GFG_Fun() {
			down.innerHTML = Factorial(n);
		}
	</script>
</body>

</html>
