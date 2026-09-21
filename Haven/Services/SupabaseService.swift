import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://nbfncdmphhqaejpqmboq.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iZm5jZG1waGhxYWVqcHFtYm9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4NjQ2ODEsImV4cCI6MjEwNDQ0MDY4MX0.d92XlWJKDWBrSxh2NLxK7sqh0nOQ-kDh5w9aKPqYnPA"
        )
    }
}

