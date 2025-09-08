import Testing
import Foundation
@testable import RobylonSDK

// MARK: - ChatbotUtils Tests
struct ChatbotUtilsTests {
    
    // MARK: - User Profile JSON Creation Tests
    @Test func testCreateUserProfileJavaScriptWithNilProfile() async throws {
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: nil, systemInfo: systemInfo)
        
        // Should contain system info
        #expect(result.contains("\"platform\": \"iOS\""))
        #expect(result.contains("\"browser\": \"WebView\""))
        #expect(result.contains("\"device\""))
        #expect(result.contains("\"screen_size\""))
        
        // Should contain default isTestUser
        #expect(result.contains("\"is_test_user\": false"))
        
        // Should be valid JSON format
        #expect(result.hasPrefix("{"))
        #expect(result.hasSuffix("}"))
    }
    
    @Test func testCreateUserProfileJavaScriptWithBasicProfile() async throws {
        let userProfile: [String: Any] = [
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "+1234567890"
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should contain user profile data
        #expect(result.contains("\"name\": \"John Doe\""))
        #expect(result.contains("\"email\": \"john@example.com\""))
        #expect(result.contains("\"phone\": \"+1234567890\""))
        
        // Should contain system info
        #expect(result.contains("\"platform\": \"iOS\""))
        
        // Should contain default isTestUser since not specified
        #expect(result.contains("\"is_test_user\": false"))
    }
    
    @Test func testCreateUserProfileJavaScriptWithCompleteProfile() async throws {
        let userProfile: [String: Any] = [
            "name": "Jane Smith",
            "email": "jane@company.com",
            "phone": "+9876543210",
            "company": "Tech Corp",
            "department": "Engineering",
            "user_id": "user123",
            "subscription": "premium",
            "is_test_user": true
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should contain all user profile data
        #expect(result.contains("\"name\": \"Jane Smith\""))
        #expect(result.contains("\"email\": \"jane@company.com\""))
        #expect(result.contains("\"phone\": \"+9876543210\""))
        #expect(result.contains("\"company\": \"Tech Corp\""))
        #expect(result.contains("\"department\": \"Engineering\""))
        #expect(result.contains("\"user_id\": \"user123\""))
        #expect(result.contains("\"subscription\": \"premium\""))
        #expect(result.contains("\"is_test_user\": true"))
        
        // Should contain system info
        #expect(result.contains("\"platform\": \"iOS\""))
        #expect(result.contains("\"browser\": \"WebView\""))
    }
    
    @Test func testCreateUserProfileJavaScriptWithCustomFields() async throws {
        let userProfile: [String: Any] = [
            "name": "Admin User",
            "role": "admin",
            "level": "senior",
            "location": "San Francisco"
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should contain custom fields
        #expect(result.contains("\"role\": \"admin\""))
        #expect(result.contains("\"level\": \"senior\""))
        #expect(result.contains("\"location\": \"San Francisco\""))
        
        // Should contain name
        #expect(result.contains("\"name\": \"Admin User\""))
    }
    
    @Test func testCreateUserProfileJavaScriptWithSpecialCharacters() async throws {
        let userProfile: [String: Any] = [
            "name": "José María",
            "email": "jose.maria@español.com",
            "company": "Café & Co."
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should properly escape special characters
        #expect(result.contains("\"name\": \"José María\""))
        #expect(result.contains("\"email\": \"jose.maria@español.com\""))
        #expect(result.contains("\"company\": \"Café & Co.\""))
    }
    
    @Test func testCreateUserProfileJavaScriptWithQuotesInData() async throws {
        let userProfile: [String: Any] = [
            "name": "John \"Johnny\" Doe",
            "company": "Company \"The Best\" Inc."
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should properly escape quotes
        #expect(result.contains("\"name\": \"John \\\"Johnny\\\" Doe\""))
        #expect(result.contains("\"company\": \"Company \\\"The Best\\\" Inc.\""))
    }
    
    @Test func testCreateUserProfileJavaScriptDataTypes() async throws {
        let userProfile: [String: Any] = [
            "name": "Test User",
            "is_test_user": true,
            "age": 25,
            "score": 98.5
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Boolean should not be quoted
        #expect(result.contains("\"is_test_user\": true"))
        
        // String should be quoted
        #expect(result.contains("\"name\": \"Test User\""))
        
        // Numbers should not be quoted
        #expect(result.contains("\"age\": 25"))
        #expect(result.contains("\"score\": 98.5"))
    }
    
    @Test func testCreateUserProfileJavaScriptJSONStructure() async throws {
        let userProfile: [String: Any] = [
            "name": "Test User",
            "email": "test@example.com"
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should be valid JSON structure
        #expect(result.hasPrefix("{"))
        #expect(result.hasSuffix("}"))
        
        // Should contain proper key-value pairs
        #expect(result.contains(": "))
        
        // Should not contain any unescaped quotes in the middle
        let lines = result.components(separatedBy: ",")
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.contains("\"") {
                // Count quotes - should be even number for proper escaping
                let quoteCount = trimmedLine.filter { $0 == "\"" }.count
                #expect(quoteCount % 2 == 0, "Unescaped quotes found in: \(trimmedLine)")
            }
        }
    }
    
    @Test func testCreateUserProfileJavaScriptSystemInfoOrder() async throws {
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: nil, systemInfo: systemInfo)
        
        // System info should come first (before user profile data)
        let platformIndex = result.range(of: "\"platform\"")?.lowerBound
        let browserIndex = result.range(of: "\"browser\"")?.lowerBound
        let deviceIndex = result.range(of: "\"device\"")?.lowerBound
        
        #expect(platformIndex != nil)
        #expect(browserIndex != nil)
        #expect(deviceIndex != nil)
        
        // Platform should come before browser
        #expect(platformIndex! < browserIndex!)
        // Browser should come before device
        #expect(browserIndex! < deviceIndex!)
    }
}

// MARK: - User Profile Dictionary Validation Tests
struct UserProfileDictionaryTests {
    
    @Test func testUserProfileDictionaryWithMixedDataTypes() async throws {
        let userProfile: [String: Any] = [
            "name": "Test User",
            "age": 25,
            "isActive": true,
            "score": 98.5,
            "tags": ["premium", "vip"],
            "metadata": ["role": "admin", "level": "senior"]
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should handle different data types correctly
        #expect(result.contains("\"name\": \"Test User\""))
        #expect(result.contains("\"age\": 25"))
        #expect(result.contains("\"isActive\": true"))
        #expect(result.contains("\"score\": 98.5"))
        #expect(result.contains("\"tags\": [\"premium\", \"vip\"]"))
        #expect(result.contains("\"metadata\": {\"role\": \"admin\", \"level\": \"senior\"}"))
    }
    
    @Test func testUserProfileDictionaryWithNilValues() async throws {
        let userProfile: [String: Any] = [
            "name": "Test User",
            "email": NSNull()
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should handle nil values correctly
        #expect(result.contains("\"name\": \"Test User\""))
        #expect(result.contains("\"email\": null"))        
    }
    
    @Test func testUserProfileDictionaryWithEmptyValues() async throws {
        let userProfile: [String: Any] = [
            "name": "",
            "email": "test@example.com",
            "emptyArray": [],
            "emptyDict": [:]
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should handle empty values correctly
        #expect(result.contains("\"name\": \"\""))
        #expect(result.contains("\"email\": \"test@example.com\""))
        #expect(result.contains("\"emptyArray\": []"))
        #expect(result.contains("\"emptyDict\": {}"))
    }
    
    @Test func testUserProfileDictionaryWithComplexNestedStructures() async throws {
        let userProfile: [String: Any] = [
            "user": [
                "name": "John Doe",
                "preferences": [
                    "theme": "dark",
                    "notifications": true
                ]
            ],
            "permissions": ["read", "write", "admin"]
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
        
        // Should handle nested structures correctly
        #expect(result.contains("\"user\": {\"name\": \"John Doe\", \"preferences\": {\"theme\": \"dark\", \"notifications\": true}}"))
        #expect(result.contains("\"permissions\": [\"read\", \"write\", \"admin\"]"))
    }
    
    @Test func testUserProfileDictionaryValidation() async throws {
        // Test that the function handles various edge cases without crashing
        let edgeCases: [[String: Any]] = [
            [:], // Empty dictionary
            ["key": "value"], // Simple key-value
            ["number": 42, "bool": true, "string": "test"], // Mixed types
            ["special": "chars: !@#$%^&*()"], // Special characters
            ["unicode": "🚀🌟💫"], // Unicode characters
            ["quotes": "\"double\" and 'single' quotes"] // Quote handling
        ]
        
        let systemInfo = ChatbotUtils.getSystemInfo()
        
        for userProfile in edgeCases {
            let result = ChatbotUtils.createUserProfileJavaScript(from: userProfile, systemInfo: systemInfo)
            
            // Should always produce valid JSON structure
            #expect(result.hasPrefix("{"))
            #expect(result.hasSuffix("}"))
            #expect(!result.isEmpty)
        }
    }
}
