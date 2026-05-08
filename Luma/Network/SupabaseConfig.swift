//
//  SupabaseConfig.swift
//  Luma
//

import Foundation

enum SupabaseConfig {
    static let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        ?? "https://bikvyomatpnktvjpkfai.supabase.co"

    static let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpa3Z5b21hdHBua3R2anBrZmFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3OTYyNDIsImV4cCI6MjA4ODM3MjI0Mn0.xxbzxcY3MyKcJvnsQCaNYEVppFGJAGsFjXGNQqbYxdg"
}
