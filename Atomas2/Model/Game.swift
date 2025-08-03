import Foundation
import CoreData

// Puzzle structure in json
struct GameData: Codable {
  let score: Int
  let center: Int
  let board: [Int]
}

var initGame: GameData = GameData(
  score: -1,
  center: -1,
  board: []
)

// Transformer for board
@objc(ArrayIntTransformer)
class ArrayIntTransformer: NSSecureUnarchiveFromDataTransformer {
  override class var allowedTopLevelClasses: [AnyClass] {
    return [NSArray.self, NSNumber.self]
  }

  static let name = NSValueTransformerName(rawValue: String(describing: ArrayIntTransformer.self))

  public static func register() {
    let transformer = ArrayIntTransformer()
    ValueTransformer.setValueTransformer(transformer, forName: name)
  }
}

var elements = [
  1: [
      "symbol": "H",
      "name": "Hydrogen",
      "color": 0x63b9d5
  ],
  2: [
      "symbol": "He",
      "name": "Helium",
      "color": 0xd1c991
  ],
  3: [
      "symbol": "Li",
      "name": "Lithium",
      "color": 0x4c6168
  ],
  4: [
      "symbol": "Be",
      "name": "Beryllium",
      "color": 0xc8c8c8
  ],
  5: [
      "symbol": "B",
      "name": "Boron",
      "color": 0x7d5353
  ],
  6: [
      "symbol": "C",
      "name": "Carbon",
      "color": 0x3b3b3b
  ],
  7: [
      "symbol": "N",
      "name": "Nitrogen",
      "color": 0x2cc6b2
  ],
  8: [
      "symbol": "O",
      "name": "Oxygen",
      "color": 0x6fec98
  ],
  9: [
      "symbol": "F",
      "name": "Fluorine",
      "color": 0xecc46f
  ],
  10: [
      "symbol": "Ne",
      "name": "Neon",
      "color": 0xbe0086
  ],
  11: [
      "symbol": "Na",
      "name": "Sodium",
      "color": 0xe69d7a
  ],
  12: [
      "symbol": "Mg",
      "name": "Magnesium",
      "color": 0x9e80ea
  ],
  13: [
      "symbol": "Al",
      "name": "Aluminum",
      "color": 0x797979
  ],
  14: [
      "symbol": "Si",
      "name": "Silicon",
      "color": 0x4a4070
  ],
  15: [
      "symbol": "P",
      "name": "Phosphorus",
      "color": 0xd7463f
  ],
  16: [
      "symbol": "S",
      "name": "Sulfur",
      "color": 0x375e7c
  ],
  17: [
      "symbol": "Cl",
      "name": "Chlorine",
      "color": 0x6d1d7b
  ],
  18: [
      "symbol": "Ar",
      "name": "Argon",
      "color": 0x9a3da5
  ],
  19: [
      "symbol": "K",
      "name": "Potassium",
      "color": 0x4d8946
  ],
  20: [
      "symbol": "Ca",
      "name": "Calcium",
      "color": 0xf0f0f0
  ],
  21: [
      "symbol": "Sc",
      "name": "Scandium",
      "color": 0x5fbb77
  ],
  22: [
      "symbol": "Ti",
      "name": "Titanium",
      "color": 0x5a5a5a
  ],
  23: [
      "symbol": "V",
      "name": "Vanadium",
      "color": 0x5f9ebb
  ],
  24: [
      "symbol": "Cr",
      "name": "Chromium",
      "color": 0xa488b5
  ],
  25: [
      "symbol": "Mn",
      "name": "Manganese",
      "color": 0xdc4a4a
  ],
  26: [
      "symbol": "Fe",
      "name": "Iron",
      "color": 0xab967d
  ],
  27: [
      "symbol": "Co",
      "name": "Cobalt",
      "color": 0x4371e6
  ],
  28: [
      "symbol": "Ni",
      "name": "Nickel",
      "color": 0xbac395
  ],
  29: [
      "symbol": "Cu",
      "name": "Copper",
      "color": 0xb95739
  ],
  30: [
      "symbol": "Zn",
      "name": "Zinc",
      "color": 0xb4b4b4
  ],
  31: [
      "symbol": "Ga",
      "name": "Gallium",
      "color": 0x39b975
  ],
  32: [
      "symbol": "Ge",
      "name": "Germanium",
      "color": 0x979273
  ],
  33: [
      "symbol": "As",
      "name": "Arsenic",
      "color": 0x738498
  ],
  34: [
      "symbol": "Se",
      "name": "Selenium",
      "color": 0x424242
  ],
  35: [
      "symbol": "Br",
      "name": "Bromine",
      "color": 0xd4753c
  ],
  36: [
      "symbol": "Kr",
      "name": "Krypton",
      "color": 0x3ca0d4
  ],
  37: [
      "symbol": "Rb",
      "name": "Rubidium",
      "color": 0xd22c1f
  ],
  38: [
      "symbol": "Sr",
      "name": "Strontium",
      "color": 0xff9d29
  ],
  39: [
      "symbol": "Y",
      "name": "Yttrium",
      "color": 0xb129ff
  ],
  40: [
      "symbol": "Zr",
      "name": "Zirconium",
      "color": 0xd6e43a
  ],
  41: [
      "symbol": "Nb",
      "name": "Niobium",
      "color": 0x75dceb
  ],
  42: [
      "symbol": "Mo",
      "name": "Molybdenum",
      "color": 0x8ba38c
  ],
  43: [
      "symbol": "Tc",
      "name": "Technetium",
      "color": 0xeea1e2
  ],
  44: [
      "symbol": "Ru",
      "name": "Ruthenium",
      "color": 0x563e32
  ],
  45: [
      "symbol": "Rh",
      "name": "Rhodium",
      "color": 0x88d17a
  ],
  46: [
      "symbol": "Pd",
      "name": "Palladium",
      "color": 0x9eabbe
  ],
  47: [
      "symbol": "Ag",
      "name": "Silver",
      "color": 0xdcdcdc
  ],
  48: [
      "symbol": "Cd",
      "name": "Cadmium",
      "color": 0x5560c8
  ],
  49: [
      "symbol": "In",
      "name": "Indium",
      "color": 0x408d3c
  ],
  50: [
      "symbol": "Sn",
      "name": "Tin",
      "color": 0xb5a47c
  ],
  51: [
      "symbol": "Sb",
      "name": "Antimony",
      "color": 0xc6598c
  ],
  52: [
      "symbol": "Te",
      "name": "Tellurium",
      "color": 0x827498
  ],
  53: [
      "symbol": "I",
      "name": "Iodine",
      "color": 0xff00fc
  ],
  54: [
      "symbol": "Xe",
      "name": "Xenon",
      "color": 0x7888ff
  ],
  55: [
      "symbol": "Cs",
      "name": "Cesium",
      "color": 0xffd478
  ],
  56: [
      "symbol": "Ba",
      "name": "Barium",
      "color": 0xe99c9c
  ],
  57: [
      "symbol": "La",
      "name": "Lanthanum",
      "color": 0x8bdbbe
  ],
  58: [
      "symbol": "Ce",
      "name": "Cerium",
      "color": 0xff9329
  ],
  59: [
      "symbol": "Pr",
      "name": "Praseodymium",
      "color": 0x56e019
  ],
  60: [
      "symbol": "Nd",
      "name": "Neodymium",
      "color": 0x65898d
  ],
  61: [
      "symbol": "Pm",
      "name": "Promethium",
      "color": 0x2ee99b
  ],
  62: [
      "symbol": "Sm",
      "name": "Samarium",
      "color": 0xbd6475
  ],
  63: [
      "symbol": "Eu",
      "name": "Europium",
      "color": 0x6c64bd
  ],
  64: [
      "symbol": "Gd",
      "name": "Gadolinium",
      "color": 0x6e1289
  ],
  65: [
      "symbol": "Tb",
      "name": "Terbium",
      "color": 0x359c50
  ],
  66: [
      "symbol": "Dy",
      "name": "Dysprosium",
      "color": 0x447ee7
  ],
  67: [
      "symbol": "Ho",
      "name": "Holmium",
      "color": 0xe77d46
  ],
  68: [
      "symbol": "Er",
      "name": "Erbium",
      "color": 0xbf4987
  ],
  69: [
      "symbol": "Tm",
      "name": "Thulium",
      "color": 0x21426b
  ],
  70: [
      "symbol": "Yb",
      "name": "Ytterbium",
      "color": 0x878750
  ],
  71: [
      "symbol": "Lu",
      "name": "Lutetium",
      "color": 0xd12c2c
  ],
  72: [
      "symbol": "Hf",
      "name": "Hafnium",
      "color": 0x91d12c
  ],
  73: [
      "symbol": "Ta",
      "name": "Tantalum",
      "color": 0x7f87af
  ],
  74: [
      "symbol": "W",
      "name": "Tungsten",
      "color": 0x2b6aa5
  ],
  75: [
      "symbol": "Re",
      "name": "Rhenium",
      "color": 0x512f2f
  ],
  76: [
      "symbol": "Os",
      "name": "Osmium",
      "color": 0x307060
  ],
  77: [
      "symbol": "Ir",
      "name": "Iridium",
      "color": 0xc9876a
  ],
  78: [
      "symbol": "Pt",
      "name": "Platinum",
      "color": 0x505008
  ],
  79: [
      "symbol": "Au",
      "name": "Gold",
      "color": 0xedc474
  ],
  80: [
      "symbol": "Hg",
      "name": "Mercury",
      "color": 0x80a5ac
  ],
  81: [
      "symbol": "Tl",
      "name": "Thallium",
      "color": 0xac8089
  ],
  82: [
      "symbol": "Pb",
      "name": "Lead",
      "color": 0x3c7c66
  ],
  83: [
      "symbol": "Bi",
      "name": "Bismuth",
      "color": 0xff0506
  ],
  84: [
      "symbol": "Po",
      "name": "Polonium",
      "color": 0xffff00
  ],
  85: [
      "symbol": "At",
      "name": "Astatine",
      "color": 0x00ff00
  ],
  86: [
      "symbol": "Rn",
      "name": "Radon",
      "color": 0xdae83a
  ],
  87: [
      "symbol": "Fr",
      "name": "Francium",
      "color": 0xff6c00
  ],
  88: [
      "symbol": "Ra",
      "name": "Radium",
      "color": 0x00ffff
  ],
  89: [
      "symbol": "Ac",
      "name": "Actinium",
      "color": 0x424918
  ],
  90: [
      "symbol": "Th",
      "name": "Thorium",
      "color": 0xaa3d82
  ],
  91: [
      "symbol": "Pa",
      "name": "Protactinium",
      "color": 0x3daa82
  ],
  92: [
      "symbol": "U",
      "name": "Uranium",
      "color": 0x9cff00
  ],
  93: [
      "symbol": "Np",
      "name": "Neptunium",
      "color": 0x00aeff
  ],
  94: [
      "symbol": "Pu",
      "name": "Plutonium",
      "color": 0xff9000
  ],
  95: [
      "symbol": "Am",
      "name": "Americium",
      "color": 0x813349
  ],
  96: [
      "symbol": "Cm",
      "name": "Curium",
      "color": 0xff79d0
  ],
  97: [
      "symbol": "Bk",
      "name": "Berkelium",
      "color": 0xae877e
  ],
  98: [
      "symbol": "Cf",
      "name": "Californium",
      "color": 0x8f3cb4
  ],
  99: [
      "symbol": "Es",
      "name": "Einsteinium",
      "color": 0x86c4dc
  ],
  100: [
      "symbol": "Fm",
      "name": "Fermium",
      "color": 0xbfdc86
  ],
  101: [
      "symbol": "Md",
      "name": "Mendelevium",
      "color": 0xdc8686
  ],
  102: [
      "symbol": "No",
      "name": "Nobelium",
      "color": 0xffd965
  ],
  103: [
      "symbol": "Lr",
      "name": "Lawrencium",
      "color": 0x5c24a0
  ],
  104: [
      "symbol": "Rf",
      "name": "Rutherfordium",
      "color": 0x6b6675
  ],
  105: [
      "symbol": "Db",
      "name": "Dubnium",
      "color": 0xb05032
  ],
  106: [
      "symbol": "Sg",
      "name": "Seaborgium",
      "color": 0x254987
  ],
  107: [
      "symbol": "Bh",
      "name": "Bohrium",
      "color": 0x9bafa0
  ],
  108: [
      "symbol": "Hs",
      "name": "Hassium",
      "color": 0xff562d
  ],
  109: [
      "symbol": "Mt",
      "name": "Meitnerium",
      "color": 0xcdcd2c
  ],
  110: [
      "symbol": "Ds",
      "name": "Darmstadtium",
      "color": 0x3a7e48
  ],
  111: [
      "symbol": "Rg",
      "name": "Roentgenium",
      "color": 0x0000ff
  ],
  112: [
      "symbol": "Cn",
      "name": "Copernicium",
      "color": 0xaa4594
  ],
  113: [
      "symbol": "Nh",
      "name": "Nihonium",
      "color": 0x8f8f8f
  ],
  114: [
      "symbol": "Fl",
      "name": "Flerovium",
      "color": 0x2eede6
  ],
  115: [
      "symbol": "Mc",
      "name": "Moscovium",
      "color": 0xbeaf64
  ],
  116: [
      "symbol": "Lv",
      "name": "Livermorium",
      "color": 0xf22e6a
  ],
  117: [
      "symbol": "Ts",
      "name": "Tennessine",
      "color": 0x70ea78
  ],
  118: [
      "symbol": "Og",
      "name": "Oganesson",
      "color": 0xff00b9
  ],
  119: [
      "symbol": "Bn",
      "name": "Bananium",
      "color": 0xede674
  ],
  120: [
      "symbol": "Gb",
      "name": "GravityBlockium",
      "color": 0x3de6c3
  ],
  121: [
      "symbol": "Bb",
      "name": "BreakingBadium",
      "color": 0x309141
  ],
  122: [
      "symbol": "Pi",
      "name": "314159265359",
      "color": 0x4dc8e6
  ],
  123: [
      "symbol": "Sir",
      "name": "Sirnicanium",
      "color": 0xff0000
  ],
  124: [
      "symbol": "Ea",
      "name": "Earthium",
      "color": 0x1177f5
  ],
  125: [
      "symbol": "?",
      "name": "(Unknown)",
      "color": 0xffffff
  ]
]
