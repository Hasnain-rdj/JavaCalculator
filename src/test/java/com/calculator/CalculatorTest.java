package com.calculator;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

public class CalculatorTest {
    
    private Calculator calculator;
    
    @Before
    public void setUp() {
        calculator = new Calculator();
    }
    
    @Test
    public void testAdd() {
        assertEquals(5.0, calculator.add(2, 3), 0.001);
        assertEquals(0.0, calculator.add(-2, 2), 0.001);
    }
    
    @Test
    public void testSubtract() {
        assertEquals(1.0, calculator.subtract(3, 2), 0.001);
        assertEquals(-5.0, calculator.subtract(0, 5), 0.001);
    }
    
    @Test
    public void testMultiply() {
        assertEquals(6.0, calculator.multiply(2, 3), 0.001);
        assertEquals(-6.0, calculator.multiply(-2, 3), 0.001);
        assertEquals(0.0, calculator.multiply(0, 100), 0.001);
    }
    
    @Test
    public void testDivide() {
        assertEquals(2.0, calculator.divide(6, 3), 0.001);
        assertEquals(0.5, calculator.divide(1, 2), 0.001);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testDivideByZero() {
        calculator.divide(5, 0);
    }
    
    @Test
    public void testModulus() {
        assertEquals(1.0, calculator.modulus(5, 2), 0.001);
        assertEquals(0.0, calculator.modulus(6, 3), 0.001);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testModulusByZero() {
        calculator.modulus(5, 0);
    }
}
