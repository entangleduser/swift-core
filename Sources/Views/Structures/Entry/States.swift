import SwiftUI

public enum States:
 Int,
 Codable,
 Identifiable,
 CaseIterable,
 ExpressibleByNilLiteral {
 case
  none,
  alaska,
  alabama,
  arkansas,
  americanSamoa,
  arizona,
  california,
  colorado,
  connecticut,
  districtOfColumbia,
  delaware,
  florida,
  georgia,
  guam,
  hawaii,
  iowa,
  idaho,
  illinois,
  indiana,
  kansas,
  kentucky,
  louisiana,
  massachusetts,
  maryland,
  maine,
  michigan,
  minnesota,
  missouri,
  mississippi,
  montana,
  northCarolina,
  northDakota,
  nebraska,
  newHampshire,
  newJersey,
  newMexico,
  nevada,
  newYork,
  ohio,
  oklahoma,
  oregon,
  pennsylvania,
  puertoRico,
  rhodeIsland,
  southCarolina,
  southDakota,
  tennessee,
  texas,
  utah,
  virginia,
  virginIslands,
  vermont,
  washington,
  wisconsin,
  westVirginia,
  wyoming
 public var id: Int { rawValue }
 public var name: String {
  String(describing: self)
   .map { $0.isUppercase ? " " + String($0) : String($0) }
   .joined()
   .capitalized
 }

 public var abbreviation: String? {
  switch self {
  case .alaska: return "AK"
  case .alabama: return "AL"
  case .arkansas: return "AR"
  case .americanSamoa: return "AS"
  case .arizona: return "AZ"
  case .california: return "CA"
  case .colorado: return "CO"
  case .connecticut: return "CT"
  case .districtOfColumbia: return "DC"
  case .delaware: return "DE"
  case .florida: return "FL"
  case .georgia: return "GA"
  case .guam: return "GU"
  case .hawaii: return "HI"
  case .iowa: return "IA"
  case .idaho: return "ID"
  case .illinois: return "IL"
  case .indiana: return "IN"
  case .kansas: return "KS"
  case .kentucky: return "KY"
  case .louisiana: return "LA"
  case .massachusetts: return "MA"
  case .maryland: return "MD"
  case .maine: return "ME"
  case .michigan: return "MI"
  case .minnesota: return "MN"
  case .missouri: return "MO"
  case .mississippi: return "MS"
  case .montana: return "MT"
  case .northCarolina: return "NC"
  case .northDakota: return "ND"
  case .nebraska: return "NE"
  case .newHampshire: return "NH"
  case .newJersey: return "NJ"
  case .newMexico: return "NM"
  case .nevada: return "NV"
  case .newYork: return "NY"
  case .ohio: return "OH"
  case .oklahoma: return "OK"
  case .oregon: return "OR"
  case .pennsylvania: return "PA"
  case .puertoRico: return "PR"
  case .rhodeIsland: return "RI"
  case .southCarolina: return "SC"
  case .southDakota: return "SD"
  case .tennessee: return "TN"
  case .texas: return "TX"
  case .utah: return "UT"
  case .virginia: return "VA"
  case .virginIslands: return "VI"
  case .vermont: return "VT"
  case .washington: return "WA"
  case .wisconsin: return "WI"
  case .westVirginia: return "WV"
  case .wyoming: return "WY"
  default: return .none
  }
 }

 public init() { self.init(rawValue: .zero)! }
 public init(nilLiteral _: ()) { self.init() }
}
