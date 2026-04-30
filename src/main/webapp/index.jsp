<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Java Calculator</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            width: 400px;
        }
        
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            font-size: 28px;
        }
        
        .calculator-form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        label {
            color: #555;
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 14px;
        }
        
        input, select {
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        input:focus, select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .operations {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        
        .operations label {
            margin-bottom: 0;
            display: flex;
            align-items: center;
            font-weight: 400;
        }
        
        .operations input {
            margin-right: 5px;
            cursor: pointer;
        }
        
        button {
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .result {
            margin-top: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            border-radius: 5px;
            display: none;
        }
        
        .result.show {
            display: block;
        }
        
        .result h3 {
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .result p {
            color: #333;
            font-size: 16px;
        }
        
        .error {
            background: #ffe0e0 !important;
            border-left-color: #ff6b6b !important;
        }
        
        .error h3 {
            color: #ff6b6b !important;
        }
        
        .loading {
            display: none;
            text-align: center;
            color: #667eea;
        }
        
        .version {
            text-align: center;
            margin-top: 20px;
            color: #999;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧮 Calculator</h1>
        
        <form class="calculator-form" onsubmit="calculateResult(event)">
            <div class="form-group">
                <label for="num1">First Number:</label>
                <input type="number" id="num1" name="num1" step="any" required>
            </div>
            
            <div class="form-group">
                <label>Operation:</label>
                <div class="operations">
                    <label>
                        <input type="radio" name="operation" value="add" checked> Add (+)
                    </label>
                    <label>
                        <input type="radio" name="operation" value="subtract"> Subtract (-)
                    </label>
                    <label>
                        <input type="radio" name="operation" value="multiply"> Multiply (×)
                    </label>
                    <label>
                        <input type="radio" name="operation" value="divide"> Divide (÷)
                    </label>
                    <label>
                        <input type="radio" name="operation" value="modulus"> Modulus (%)
                    </label>
                </div>
            </div>
            
            <div class="form-group">
                <label for="num2">Second Number:</label>
                <input type="number" id="num2" name="num2" step="any" required>
            </div>
            
            <button type="submit">Calculate</button>
            
            <div class="loading" id="loading">
                Calculating...
            </div>
        </form>
        
        <div class="result" id="result"></div>
        
        <div class="version">
            v1.0.0 | Java Calculator CI/CD
        </div>
    </div>
    
    <script>
        function calculateResult(event) {
            event.preventDefault();
            
            const num1 = document.getElementById('num1').value;
            const num2 = document.getElementById('num2').value;
            const operation = document.querySelector('input[name="operation"]:checked').value;
            const loading = document.getElementById('loading');
            const resultDiv = document.getElementById('result');
            
            loading.style.display = 'block';
            resultDiv.classList.remove('show', 'error');
            
            fetch('/calculator/calculate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'num1=' + num1 + '&num2=' + num2 + '&operation=' + operation
            })
            .then(response => response.json())
            .then(data => {
                loading.style.display = 'none';
                
                if (data.error) {
                    resultDiv.classList.add('error');
                    resultDiv.innerHTML = '<h3>Error</h3><p>' + data.error + '</p>';
                } else {
                    resultDiv.innerHTML = '<h3>Result</h3><p>' + num1 + ' ' + getOperationSymbol(operation) + ' ' + num2 + ' = <strong>' + data.result + '</strong></p>';
                }
                
                resultDiv.classList.add('show');
            })
            .catch(error => {
                loading.style.display = 'none';
                resultDiv.classList.add('error');
                resultDiv.innerHTML = '<h3>Error</h3><p>Failed to connect to server</p>';
                resultDiv.classList.add('show');
                console.error('Error:', error);
            });
        }
        
        function getOperationSymbol(op) {
            const symbols = {
                'add': '+',
                'subtract': '-',
                'multiply': '×',
                'divide': '÷',
                'modulus': '%'
            };
            return symbols[op] || op;
        }
    </script>
</body>
</html>
