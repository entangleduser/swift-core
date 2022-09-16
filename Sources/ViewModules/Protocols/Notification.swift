import protocol Storage.JSONCodable
import Foundation

public protocol Notification: JSONCodable {
 associatedtype Info: JSONCodable
 var title: String? { get set }
 var subtitle: String? { get set }
 var body: String? { get set }
 var sound: String? { get set }
 var badge: Int? { get set }
 var action: NotificationAction? { get set }
 //var category: NotificationAction? { get set }
 var info: Info { get set }
 init()
}

public extension Notification {
 typealias CodingKeys = NotificationCodingKeys
 //var category: NotificationAction? { get { action } set { action = newValue } }
 func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: NotificationCodingKeys.self)
  try container.encodeIfPresent(title, forKey: .title)
  try container.encodeIfPresent(subtitle, forKey: .subtitle)
  try container.encodeIfPresent(body, forKey: .body)
  try container.encodeIfPresent(sound, forKey: .sound)
  if let badge = badge {
   try container.encodeIfPresent(badge.description, forKey: .badge)
  }
  try container.encodeIfPresent(action, forKey: .action)
 }

 init(from decoder: Swift.Decoder) throws {
  self.init()
  let container = try decoder.container(keyedBy: NotificationCodingKeys.self)
  title = try container.decodeIfPresent(String.self, forKey: .title)
  subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
  body = try container.decodeIfPresent(String.self, forKey: .body)
  sound = try container.decodeIfPresent(String.self, forKey: .sound)
  if let badge = try container.decodeIfPresent(String.self, forKey: .badge) {
   self.badge = Int(badge)
  }
  action = try container.decodeIfPresent(NotificationAction.self, forKey: .action)
//  if let string = try container.decodeIfPresent(String.self, forKey: .category),
//     let category = NotificationAction(rawValue: string) {
//   self.category = category
//  }
 }
}

public enum NotificationCodingKeys: String, CodingKey {
 case title, subtitle, body, sound, badge, action = "click_action"//, category
}

public enum NotificationAction: String, Codable, CustomStringConvertible {
 case view
 public var description: String { rawValue }
}
