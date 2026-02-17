package com.realestate.api.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Drops ALL foreign keys first, then drops all tables.
 * Flyway will recreate everything (V1 schema + V2 test data) on next Spring Boot startup.
 *
 * Run with: mvn -q exec:java "-Dexec.mainClass=com.realestate.api.util.DatabaseCleaner"
 */
public class DatabaseCleaner {

    private static final String URL = "jdbc:sqlserver://ASUSAURELIEN\\SQLEXPRESS00;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
    private static final String PASSWORD = "password";

    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("DATABASE RESET - DROP ALL TABLES");
        System.out.println("========================================");
        System.out.println("Target: " + URL);
        System.out.println();

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = conn.createStatement()) {

            // Step 1: Drop all foreign key constraints
            System.out.println("Dropping all foreign key constraints...");
            List<String[]> fks = new ArrayList<>();
            ResultSet rs = stmt.executeQuery(
                "SELECT fk.name AS fk_name, t.name AS table_name " +
                "FROM sys.foreign_keys fk " +
                "JOIN sys.tables t ON fk.parent_object_id = t.object_id"
            );
            while (rs.next()) {
                fks.add(new String[]{rs.getString("fk_name"), rs.getString("table_name")});
            }
            rs.close();

            for (String[] fk : fks) {
                stmt.executeUpdate("ALTER TABLE [" + fk[1] + "] DROP CONSTRAINT [" + fk[0] + "]");
                System.out.println("  Dropped FK: " + fk[0] + " on " + fk[1]);
            }

            // Step 2: Drop all tables
            System.out.println();
            System.out.println("Dropping all tables...");
            List<String> tables = new ArrayList<>();
            rs = stmt.executeQuery("SELECT name FROM sys.tables");
            while (rs.next()) {
                tables.add(rs.getString("name"));
            }
            rs.close();

            for (String table : tables) {
                stmt.executeUpdate("DROP TABLE [" + table + "]");
                System.out.println("  Dropped: " + table);
            }

            System.out.println();
            System.out.println("Done. Database is empty.");
            System.out.println("Start Spring Boot to run Flyway migrations (V1 schema + V2 test data).");

        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
