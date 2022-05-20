import SwiftUI
public final class Time {
 public static let shared = Time()
 public let formatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.doesRelativeDateFormatting = true
  formatter.dateStyle = .medium
  return formatter
 }()
}

public extension EnvironmentValues {
 var time: Time { .shared }
}
