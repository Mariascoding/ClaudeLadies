import Foundation
import Supabase

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://YOUR_PROJECT_ID.supabase.co")!,
        supabaseKey: "YOUR_ANON_KEY"
    )
}
