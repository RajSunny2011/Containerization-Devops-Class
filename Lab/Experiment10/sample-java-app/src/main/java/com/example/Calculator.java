package com.example;

public class Calculator {

    // ── BUG: Division by zero is not handled ──────────────
    // If someone calls divide(5, 0), this will crash at runtime.
    public int divide(int a, int b) {
        return a / b;
    }

    // ── CODE SMELL: Unused variable ────────────────────────
    // The variable 'unused' is declared but never used.
    // SonarQube flags this as unnecessary clutter.
    public int add(int a, int b) {
        int result = a + b;
        int unused = 100;   // ← code smell: delete this line
        return result;
    }

    // ── VULNERABILITY: SQL Injection risk ─────────────────
    // Building a query by concatenating user input is dangerous.
    // An attacker could pass: "1 OR 1=1" and get all users.
    public String getUser(String userId) {
        String query = "SELECT * FROM users WHERE id = " + userId;
        return query;
    }

    // ── CODE SMELL: Duplicated code ────────────────────────
    // The two methods below do exactly the same thing.
    // This is copy-paste code and should be a single method.
    public int multiply(int a, int b) {
        int result = 0;
        for (int i = 0; i < b; i++) {
            result = result + a;
        }
        return result;
    }

    public int multiplyAlt(int a, int b) {
        int result = 0;
        for (int i = 0; i < b; i++) {
            result = result + a;   // ← exact duplicate of multiply()
        }
        return result;
    }

    // ── BUG: Null pointer risk ─────────────────────────────
    // If 'name' is null, calling .toUpperCase() will throw
    // a NullPointerException at runtime.
    public String getName(String name) {
        return name.toUpperCase();
    }

    // ── CODE SMELL: Empty catch block ─────────────────────
    // The exception is caught but silently ignored.
    // This hides errors and makes debugging very hard.
    public void riskyOperation() {
        try {
            int x = 10 / 0;
        } catch (Exception e) {
            // ← never leave catch blocks empty
        }
    }
}