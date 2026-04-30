# Java Calculator Web Application

A simple, production-ready Java Calculator web application built with Maven and Tomcat.

## Features

- ✅ Basic arithmetic operations (Add, Subtract, Multiply, Divide, Modulus)
- ✅ REST API endpoint for calculations
- ✅ Modern, responsive UI
- ✅ Comprehensive unit tests
- ✅ Maven build configuration
- ✅ WAR file generation for Tomcat deployment
- ✅ CI/CD ready with Jenkins

## Project Structure

```
JavaCalculator/
├── src/
│   ├── main/
│   │   ├── java/com/calculator/
│   │   │   ├── Calculator.java         # Core calculator logic
│   │   │   └── CalculatorServlet.java  # REST API servlet
│   │   └── webapp/
│   │       ├── index.jsp               # Web UI
│   │       └── WEB-INF/
│   │           └── web.xml             # Web configuration
│   └── test/
│       └── java/com/calculator/
│           └── CalculatorTest.java     # Unit tests
├── pom.xml                               # Maven configuration
├── .gitignore                            # Git ignore file
└── README.md                             # This file
```

## Build Instructions

### Prerequisites
- Java 11 or higher
- Maven 3.6+

### Build WAR File

```bash
# Navigate to project directory
cd JavaCalculator

# Clean and build WAR
mvn clean package

# Built WAR file will be in: target/calculator.war
```

### Run Unit Tests

```bash
mvn test
```

## Deployment

### Deploy to Tomcat

1. **Copy WAR file to Tomcat webapps**
   ```bash
   cp target/calculator.war /path/to/tomcat/webapps/
   ```

2. **Restart Tomcat**
   ```bash
   # Linux/Mac
   /path/to/tomcat/bin/shutdown.sh
   /path/to/tomcat/bin/startup.sh
   
   # Windows
   cd C:\path\to\tomcat\bin
   shutdown.bat
   startup.bat
   ```

3. **Access the application**
   - Web UI: http://localhost:9090/calculator
   - API: POST http://localhost:9090/calculator/calculate

## API Usage

### Endpoint
```
POST /calculator/calculate
```

### Parameters
- `num1` (required): First number
- `num2` (required): Second number
- `operation` (required): Operation type (add, subtract, multiply, divide, modulus)

### Example Request
```bash
curl -X POST http://localhost:9090/calculator/calculate \
  -d "num1=10&num2=5&operation=add"
```

### Example Response
```json
{
  "result": 15,
  "operation": "add"
}
```

## CI/CD Pipeline

This project is configured for CI/CD with Jenkins:
- Automated builds on commit
- Unit tests execution
- WAR file generation
- Automatic deployment to Tomcat

## Version History

- v1.0.0 - Initial release

## Author

DevOps Team

## License

MIT
