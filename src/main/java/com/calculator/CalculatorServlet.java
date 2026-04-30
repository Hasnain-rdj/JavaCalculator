package com.calculator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "CalculatorServlet", urlPatterns = {"/calculate"})
public class CalculatorServlet extends HttpServlet {
    
    private Calculator calculator = new Calculator();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            double num1 = Double.parseDouble(request.getParameter("num1"));
            double num2 = Double.parseDouble(request.getParameter("num2"));
            String operation = request.getParameter("operation");
            
            double result = 0;
            
            switch(operation) {
                case "add":
                    result = calculator.add(num1, num2);
                    break;
                case "subtract":
                    result = calculator.subtract(num1, num2);
                    break;
                case "multiply":
                    result = calculator.multiply(num1, num2);
                    break;
                case "divide":
                    result = calculator.divide(num1, num2);
                    break;
                case "modulus":
                    result = calculator.modulus(num1, num2);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Invalid operation\"}");
                    return;
            }
            
            response.setStatus(HttpServletResponse.SC_OK);
            out.print("{\"result\":" + result + ",\"operation\":\"" + operation + "\"}");
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid number format\"}");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Server error: " + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.print("<h1>Calculator API</h1><p>Use POST request to /calculate endpoint</p>");
    }
}
