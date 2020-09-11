return {
  [1] = {
  ["IF"] = {
  ["unit"] = "rich village",
  ["unitkilled"] = true,
  ["defender"] = "anybody",
  ["attacker"] = "corinthians",
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "The citizens are rounded up and sold as slaves in the market in Corinth.",
  [2] = "This looks like a perfect location to found a new colony!",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "slave",
  ["owner"] = "corinthians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
}
,
}
,
  ["changemoney"] = {
  ["amount"] = 150,
  ["receiver"] = "corinthians",
}
,
}
,
}
,
  [2] = {
  ["IF"] = {
  ["unit"] = "rich village",
  ["unitkilled"] = true,
  ["defender"] = "anybody",
  ["attacker"] = "spartans",
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "The citizens are rounded up and sold as slaves in the market in Sparta.",
  [2] = "This looks like a perfect location to found a new colony! LegacyConvert",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "slave",
  ["owner"] = "spartans",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 236,
  [2] = 122,
}
,
}
,
}
,
  ["changemoney"] = {
  ["amount"] = 150,
  ["receiver"] = "spartans",
}
,
}
,
}
,
  [3] = {
  ["IF"] = {
  ["unit"] = "rich village",
  ["unitkilled"] = true,
  ["defender"] = "anybody",
  ["attacker"] = "ionians",
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "The citizens are rounded up and sold as slaves in the market in Miletus.",
  [2] = "This looks like a perfect location to found a new colony!",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "slave",
  ["owner"] = "ionians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 308,
  [2] = 102,
}
,
}
,
}
,
  ["changemoney"] = {
  ["amount"] = 150,
  ["receiver"] = "ionians",
}
,
}
,
}
,
  [4] = {
  ["IF"] = {
  ["unit"] = "rich village",
  ["unitkilled"] = true,
  ["defender"] = "anybody",
  ["attacker"] = "phoenicians",
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "The citizens are rounded up and sold as slaves in the market in Carthage.",
  [2] = "This looks like a perfect location to found a new colony!",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "slave",
  ["owner"] = "phoenicians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 37,
  [2] = 131,
}
,
}
,
}
,
  ["changemoney"] = {
  ["amount"] = 150,
  ["receiver"] = "phoenicians",
}
,
}
,
}
,
  [5] = {
  ["IF"] = {
  ["unit"] = "rich village",
  ["unitkilled"] = true,
  ["defender"] = "anybody",
  ["attacker"] = "etruscans",
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "The citizens are rounded up and sold as slaves in the market in Clusium.",
  [2] = "This looks like a perfect location to found a new colony!",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "slave",
  ["owner"] = "etruscans",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 69,
  [2] = 3,
}
,
}
,
}
,
  ["changemoney"] = {
  ["amount"] = 150,
  ["receiver"] = "etruscans",
}
,
}
,
}
,
  [6] = {
  ["IF"] = {
  ["turn"] = 210,
}
,
  ["THEN"] = {
  ["givetechnology"] = {
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["text"] = {
  ["text"] = {
  [1] = "The Persian Great King Cyrus resolves to subdue the rebelious Ionian Greeks.",
}
,
}
,
}
,
}
,
  [7] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "siege tower",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 311,
  [2] = 75,
}
,
}
,
}
,
}
,
}
,
  [8] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian kardakes",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 311,
  [2] = 75,
}
,
}
,
}
,
}
,
}
,
  [9] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian sparhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 311,
  [2] = 75,
}
,
}
,
}
,
}
,
}
,
  [10] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian takhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 311,
  [2] = 75,
}
,
}
,
}
,
}
,
}
,
  [11] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 311,
  [2] = 75,
}
,
}
,
}
,
}
,
}
,
  [12] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "siege tower",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 316,
  [2] = 94,
}
,
}
,
}
,
}
,
}
,
  [13] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian kardakes",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 316,
  [2] = 94,
}
,
}
,
}
,
}
,
}
,
  [14] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian sparhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 316,
  [2] = 94,
}
,
}
,
}
,
}
,
}
,
  [15] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian takhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 316,
  [2] = 94,
}
,
}
,
}
,
}
,
}
,
  [16] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 93,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 316,
  [2] = 94,
}
,
}
,
}
,
}
,
}
,
  [17] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["givetechnology"] = {
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["text"] = {
  ["text"] = {
  [1] = "King Xerxes gigantic Persian army embarks on an invasion of Greece.",
}
,
}
,
}
,
}
,
  [18] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "siege tower",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [19] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian kardakes",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [20] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian sparhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [21] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian takhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
  [2] = {
  [1] = 250,
  [2] = 92,
}
,
  [3] = {
  [1] = 237,
  [2] = 87,
}
,
  [4] = {
  [1] = 235,
  [2] = 75,
}
,
  [5] = {
  [1] = 227,
  [2] = 73,
}
,
  [6] = {
  [1] = 231,
  [2] = 55,
}
,
  [7] = {
  [1] = 244,
  [2] = 46,
}
,
  [8] = {
  [1] = 258,
  [2] = 36,
}
,
  [9] = {
  [1] = 275,
  [2] = 37,
}
,
  [10] = {
  [1] = 285,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [22] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [23] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian horsemen",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
  [2] = {
  [1] = 250,
  [2] = 92,
}
,
  [3] = {
  [1] = 237,
  [2] = 87,
}
,
  [4] = {
  [1] = 235,
  [2] = 75,
}
,
  [5] = {
  [1] = 227,
  [2] = 73,
}
,
  [6] = {
  [1] = 231,
  [2] = 55,
}
,
  [7] = {
  [1] = 244,
  [2] = 46,
}
,
  [8] = {
  [1] = 258,
  [2] = 36,
}
,
  [9] = {
  [1] = 275,
  [2] = 37,
}
,
  [10] = {
  [1] = 285,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [24] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian cavalry",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
  [2] = {
  [1] = 250,
  [2] = 92,
}
,
  [3] = {
  [1] = 237,
  [2] = 87,
}
,
  [4] = {
  [1] = 235,
  [2] = 75,
}
,
  [5] = {
  [1] = 227,
  [2] = 73,
}
,
  [6] = {
  [1] = 231,
  [2] = 55,
}
,
  [7] = {
  [1] = 244,
  [2] = 46,
}
,
  [8] = {
  [1] = 258,
  [2] = 36,
}
,
  [9] = {
  [1] = 275,
  [2] = 37,
}
,
  [10] = {
  [1] = 285,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [25] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "siege tower",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [26] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian kardakes",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [27] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian sparhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [28] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian takhabara",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
  [2] = {
  [1] = 250,
  [2] = 92,
}
,
  [3] = {
  [1] = 237,
  [2] = 87,
}
,
  [4] = {
  [1] = 235,
  [2] = 75,
}
,
  [5] = {
  [1] = 227,
  [2] = 73,
}
,
  [6] = {
  [1] = 231,
  [2] = 55,
}
,
  [7] = {
  [1] = 244,
  [2] = 46,
}
,
  [8] = {
  [1] = 258,
  [2] = 36,
}
,
  [9] = {
  [1] = 275,
  [2] = 37,
}
,
  [10] = {
  [1] = 285,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [29] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 109,
}
,
  [2] = {
  [1] = 246,
  [2] = 100,
}
,
  [3] = {
  [1] = 245,
  [2] = 91,
}
,
  [4] = {
  [1] = 240,
  [2] = 88,
}
,
  [5] = {
  [1] = 234,
  [2] = 82,
}
,
  [6] = {
  [1] = 229,
  [2] = 63,
}
,
  [7] = {
  [1] = 237,
  [2] = 47,
}
,
  [8] = {
  [1] = 249,
  [2] = 41,
}
,
  [9] = {
  [1] = 269,
  [2] = 35,
}
,
  [10] = {
  [1] = 287,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [30] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian horsemen",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
  [2] = {
  [1] = 250,
  [2] = 92,
}
,
  [3] = {
  [1] = 237,
  [2] = 87,
}
,
  [4] = {
  [1] = 235,
  [2] = 75,
}
,
  [5] = {
  [1] = 227,
  [2] = 73,
}
,
  [6] = {
  [1] = 231,
  [2] = 55,
}
,
  [7] = {
  [1] = 244,
  [2] = 46,
}
,
  [8] = {
  [1] = 258,
  [2] = 36,
}
,
  [9] = {
  [1] = 275,
  [2] = 37,
}
,
  [10] = {
  [1] = 285,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [31] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian cavalry",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
  [2] = {
  [1] = 250,
  [2] = 92,
}
,
  [3] = {
  [1] = 237,
  [2] = 87,
}
,
  [4] = {
  [1] = 235,
  [2] = 75,
}
,
  [5] = {
  [1] = 227,
  [2] = 73,
}
,
  [6] = {
  [1] = 231,
  [2] = 55,
}
,
  [7] = {
  [1] = 244,
  [2] = 46,
}
,
  [8] = {
  [1] = 258,
  [2] = 36,
}
,
  [9] = {
  [1] = 275,
  [2] = 37,
}
,
  [10] = {
  [1] = 285,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [32] = {
  ["IF"] = {
  ["receivedtechnology"] = true,
  ["receiver"] = "lydians",
  ["technology"] = 94,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "trireme",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 258,
  [2] = 108,
}
,
  [2] = {
  [1] = 249,
  [2] = 103,
}
,
  [3] = {
  [1] = 261,
  [2] = 105,
}
,
  [4] = {
  [1] = 261,
  [2] = 99,
}
,
  [5] = {
  [1] = 254,
  [2] = 92,
}
,
  [6] = {
  [1] = 246,
  [2] = 118,
}
,
}
,
}
,
}
,
}
,
  [33] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 230,
  [2] = 62,
}
,
  [2] = {
  [1] = 229,
  [2] = 61,
}
,
  [3] = {
  [1] = 228,
  [2] = 62,
}
,
  [4] = {
  [1] = 227,
  [2] = 63,
}
,
}
,
}
,
}
,
}
,
  [34] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 229,
  [2] = 61,
}
,
  [2] = {
  [1] = 228,
  [2] = 62,
}
,
  [3] = {
  [1] = 227,
  [2] = 63,
}
,
  [4] = {
  [1] = 230,
  [2] = 62,
}
,
}
,
}
,
}
,
}
,
  [35] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 228,
  [2] = 62,
}
,
  [2] = {
  [1] = 227,
  [2] = 63,
}
,
  [3] = {
  [1] = 230,
  [2] = 62,
}
,
  [4] = {
  [1] = 229,
  [2] = 61,
}
,
}
,
}
,
}
,
}
,
  [36] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 237,
  [2] = 45,
}
,
  [2] = {
  [1] = 238,
  [2] = 46,
}
,
  [3] = {
  [1] = 239,
  [2] = 47,
}
,
  [4] = {
  [1] = 238,
  [2] = 48,
}
,
}
,
}
,
}
,
}
,
  [37] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 238,
  [2] = 46,
}
,
  [2] = {
  [1] = 239,
  [2] = 47,
}
,
  [3] = {
  [1] = 238,
  [2] = 48,
}
,
  [4] = {
  [1] = 237,
  [2] = 45,
}
,
}
,
}
,
}
,
}
,
  [38] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 47,
}
,
  [2] = {
  [1] = 238,
  [2] = 48,
}
,
  [3] = {
  [1] = 237,
  [2] = 45,
}
,
  [4] = {
  [1] = 238,
  [2] = 46,
}
,
}
,
}
,
}
,
}
,
  [39] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 247,
  [2] = 41,
}
,
  [2] = {
  [1] = 250,
  [2] = 42,
}
,
  [3] = {
  [1] = 248,
  [2] = 40,
}
,
  [4] = {
  [1] = 249,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [40] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 250,
  [2] = 42,
}
,
  [2] = {
  [1] = 248,
  [2] = 40,
}
,
  [3] = {
  [1] = 249,
  [2] = 39,
}
,
  [4] = {
  [1] = 247,
  [2] = 41,
}
,
}
,
}
,
}
,
}
,
  [41] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 248,
  [2] = 40,
}
,
  [2] = {
  [1] = 249,
  [2] = 39,
}
,
  [3] = {
  [1] = 247,
  [2] = 41,
}
,
  [4] = {
  [1] = 250,
  [2] = 42,
}
,
}
,
}
,
}
,
}
,
  [42] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 269,
  [2] = 33,
}
,
  [2] = {
  [1] = 268,
  [2] = 34,
}
,
  [3] = {
  [1] = 267,
  [2] = 35,
}
,
  [4] = {
  [1] = 268,
  [2] = 36,
}
,
}
,
}
,
}
,
}
,
  [43] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 268,
  [2] = 34,
}
,
  [2] = {
  [1] = 267,
  [2] = 35,
}
,
  [3] = {
  [1] = 268,
  [2] = 36,
}
,
  [4] = {
  [1] = 269,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [44] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 267,
  [2] = 35,
}
,
  [2] = {
  [1] = 268,
  [2] = 36,
}
,
  [3] = {
  [1] = 269,
  [2] = 33,
}
,
  [4] = {
  [1] = 268,
  [2] = 34,
}
,
}
,
}
,
}
,
}
,
  [45] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 286,
  [2] = 38,
}
,
  [2] = {
  [1] = 285,
  [2] = 37,
}
,
  [3] = {
  [1] = 284,
  [2] = 36,
}
,
  [4] = {
  [1] = 283,
  [2] = 37,
}
,
}
,
}
,
}
,
}
,
  [46] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 285,
  [2] = 37,
}
,
  [2] = {
  [1] = 284,
  [2] = 36,
}
,
  [3] = {
  [1] = 283,
  [2] = 37,
}
,
  [4] = {
  [1] = 286,
  [2] = 38,
}
,
}
,
}
,
}
,
}
,
  [47] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 230,
  [2] = 62,
}
,
  [2] = {
  [1] = 229,
  [2] = 61,
}
,
  [3] = {
  [1] = 228,
  [2] = 62,
}
,
  [4] = {
  [1] = 227,
  [2] = 63,
}
,
}
,
}
,
}
,
}
,
  [48] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 229,
  [2] = 61,
}
,
  [2] = {
  [1] = 228,
  [2] = 62,
}
,
  [3] = {
  [1] = 227,
  [2] = 63,
}
,
  [4] = {
  [1] = 230,
  [2] = 62,
}
,
}
,
}
,
}
,
}
,
  [49] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 228,
  [2] = 62,
}
,
  [2] = {
  [1] = 227,
  [2] = 63,
}
,
  [3] = {
  [1] = 230,
  [2] = 62,
}
,
  [4] = {
  [1] = 229,
  [2] = 61,
}
,
}
,
}
,
}
,
}
,
  [50] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 237,
  [2] = 45,
}
,
  [2] = {
  [1] = 238,
  [2] = 46,
}
,
  [3] = {
  [1] = 239,
  [2] = 47,
}
,
  [4] = {
  [1] = 238,
  [2] = 48,
}
,
}
,
}
,
}
,
}
,
  [51] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 238,
  [2] = 46,
}
,
  [2] = {
  [1] = 239,
  [2] = 47,
}
,
  [3] = {
  [1] = 238,
  [2] = 48,
}
,
  [4] = {
  [1] = 237,
  [2] = 45,
}
,
}
,
}
,
}
,
}
,
  [52] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 239,
  [2] = 47,
}
,
  [2] = {
  [1] = 238,
  [2] = 48,
}
,
  [3] = {
  [1] = 237,
  [2] = 45,
}
,
  [4] = {
  [1] = 238,
  [2] = 46,
}
,
}
,
}
,
}
,
}
,
  [53] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 247,
  [2] = 41,
}
,
  [2] = {
  [1] = 250,
  [2] = 42,
}
,
  [3] = {
  [1] = 248,
  [2] = 40,
}
,
  [4] = {
  [1] = 249,
  [2] = 39,
}
,
}
,
}
,
}
,
}
,
  [54] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 250,
  [2] = 42,
}
,
  [2] = {
  [1] = 248,
  [2] = 40,
}
,
  [3] = {
  [1] = 249,
  [2] = 39,
}
,
  [4] = {
  [1] = 247,
  [2] = 41,
}
,
}
,
}
,
}
,
}
,
  [55] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 248,
  [2] = 40,
}
,
  [2] = {
  [1] = 249,
  [2] = 39,
}
,
  [3] = {
  [1] = 247,
  [2] = 41,
}
,
  [4] = {
  [1] = 250,
  [2] = 42,
}
,
}
,
}
,
}
,
}
,
  [56] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 269,
  [2] = 33,
}
,
  [2] = {
  [1] = 268,
  [2] = 34,
}
,
  [3] = {
  [1] = 267,
  [2] = 35,
}
,
  [4] = {
  [1] = 268,
  [2] = 36,
}
,
}
,
}
,
}
,
}
,
  [57] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 268,
  [2] = 34,
}
,
  [2] = {
  [1] = 267,
  [2] = 35,
}
,
  [3] = {
  [1] = 268,
  [2] = 36,
}
,
  [4] = {
  [1] = 269,
  [2] = 33,
}
,
}
,
}
,
}
,
}
,
  [58] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 286,
  [2] = 38,
}
,
  [2] = {
  [1] = 285,
  [2] = 37,
}
,
  [3] = {
  [1] = 284,
  [2] = 36,
}
,
  [4] = {
  [1] = 283,
  [2] = 37,
}
,
}
,
}
,
}
,
}
,
  [59] = {
  ["IF"] = {
  ["turn"] = 258,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "persian immortal",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 285,
  [2] = 37,
}
,
  [2] = {
  [1] = 284,
  [2] = 36,
}
,
  [3] = {
  [1] = 283,
  [2] = 37,
}
,
  [4] = {
  [1] = 286,
  [2] = 38,
}
,
}
,
}
,
}
,
}
,
  [60] = {
  ["IF"] = {
  ["turn"] = "every",
}
,
  ["THEN"] = {
  ["makeaggression"] = {
  ["who"] = "lydians",
  ["whom"] = "ionians",
}
,
}
,
}
,
  [61] = {
  ["IF"] = {
  ["turn"] = "every",
}
,
  ["THEN"] = {
  ["makeaggression"] = {
  ["who"] = "lydians",
  ["whom"] = "athenians",
}
,
}
,
}
,
  [62] = {
  ["IF"] = {
  ["turn"] = "every",
}
,
  ["THEN"] = {
  ["makeaggression"] = {
  ["who"] = "lydians",
  ["whom"] = "corinthians",
}
,
}
,
}
,
  [63] = {
  ["IF"] = {
  ["turn"] = "every",
}
,
  ["THEN"] = {
  ["makeaggression"] = {
  ["who"] = "lydians",
  ["whom"] = "spartans",
}
,
}
,
}
,
  [64] = {
  ["IF"] = {
  ["turn"] = "every",
}
,
  ["THEN"] = {
  ["makeaggression"] = {
  ["who"] = "lydians",
  ["whom"] = "etruscans",
}
,
}
,
}
,
  [65] = {
  ["IF"] = {
  ["turn"] = "every",
}
,
  ["THEN"] = {
  ["makeaggression"] = {
  ["who"] = "lydians",
  ["whom"] = "phoenicians",
}
,
}
,
}
,
  [66] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 20,
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "A new Strategos has risen to lead the Athenians to victory.",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "strategos",
  ["owner"] = "athenians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 255,
  [2] = 99,
}
,
}
,
}
,
}
,
}
,
  [67] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 20,
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "A new Strategos has risen to lead the Spartans to victory.",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "strategos",
  ["owner"] = "spartans",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 236,
  [2] = 122,
}
,
}
,
}
,
}
,
}
,
  [68] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 20,
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "A new Strategos has risen to lead the Corinthians to victory.",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "strategos",
  ["owner"] = "corinthians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 242,
  [2] = 102,
}
,
}
,
}
,
}
,
}
,
  [69] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 20,
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "A new Strategos has risen to lead the Ionians to victory.",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "strategos",
  ["owner"] = "ionians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 308,
  [2] = 102,
}
,
  [2] = {
  [1] = 252,
  [2] = 88,
}
,
}
,
}
,
}
,
}
,
  [70] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 20,
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "A new Strategos has risen to lead the Etruscans to victory.",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "strategos",
  ["owner"] = "etruscans",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 69,
  [2] = 3,
}
,
}
,
}
,
}
,
}
,
  [71] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 20,
}
,
  ["THEN"] = {
  ["text"] = {
  ["text"] = {
  [1] = "A new Strategos has risen to lead the Phoenicians to victory.",
}
,
}
,
  ["createunit"] = {
  ["unit"] = "strategos",
  ["owner"] = "phoenicians",
  ["homecity"] = "none",
  ["veteran"] = "no",
  ["locations"] = {
  [1] = {
  [1] = 37,
  [2] = 131,
}
,
}
,
}
,
}
,
}
,
  [72] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "skythian archer",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 298,
  [2] = 4,
}
,
  [2] = {
  [1] = 286,
  [2] = 4,
}
,
  [3] = {
  [1] = 304,
  [2] = 12,
}
,
}
,
}
,
}
,
}
,
  [73] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "skythian horseman",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 303,
  [2] = 21,
}
,
  [2] = {
  [1] = 283,
  [2] = 11,
}
,
  [3] = {
  [1] = 287,
  [2] = 25,
}
,
}
,
}
,
}
,
}
,
  [74] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "thracian warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 280,
  [2] = 22,
}
,
  [2] = {
  [1] = 262,
  [2] = 22,
}
,
  [3] = {
  [1] = 234,
  [2] = 16,
}
,
}
,
}
,
}
,
}
,
  [75] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "macedonian warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 214,
  [2] = 44,
}
,
  [2] = {
  [1] = 225,
  [2] = 33,
}
,
  [3] = {
  [1] = 217,
  [2] = 31,
}
,
}
,
}
,
}
,
}
,
  [76] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "thessalian cavalry",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 229,
  [2] = 69,
}
,
  [2] = {
  [1] = 224,
  [2] = 60,
}
,
  [3] = {
  [1] = 231,
  [2] = 75,
}
,
}
,
}
,
}
,
}
,
  [77] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "cretan archer",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 290,
  [2] = 152,
}
,
  [2] = {
  [1] = 275,
  [2] = 153,
}
,
  [3] = {
  [1] = 264,
  [2] = 152,
}
,
}
,
}
,
}
,
}
,
  [78] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "illyrian warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 166,
  [2] = 14,
}
,
  [2] = {
  [1] = 186,
  [2] = 28,
}
,
  [3] = {
  [1] = 186,
  [2] = 52,
}
,
}
,
}
,
}
,
}
,
  [79] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "rhodian slinger",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 339,
  [2] = 121,
}
,
  [2] = {
  [1] = 327,
  [2] = 125,
}
,
}
,
}
,
}
,
}
,
  [80] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "illyrian warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 166,
  [2] = 14,
}
,
  [2] = {
  [1] = 186,
  [2] = 28,
}
,
  [3] = {
  [1] = 186,
  [2] = 52,
}
,
}
,
}
,
}
,
}
,
  [81] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "liburnae",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 149,
  [2] = 5,
}
,
  [2] = {
  [1] = 180,
  [2] = 30,
}
,
  [3] = {
  [1] = 169,
  [2] = 21,
}
,
}
,
}
,
}
,
}
,
  [82] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "samnite warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 109,
  [2] = 35,
}
,
  [2] = {
  [1] = 87,
  [2] = 21,
}
,
  [3] = {
  [1] = 121,
  [2] = 47,
}
,
}
,
}
,
}
,
}
,
  [83] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "latin spearman",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 84,
  [2] = 26,
}
,
  [2] = {
  [1] = 98,
  [2] = 38,
}
,
  [3] = {
  [1] = 80,
  [2] = 16,
}
,
}
,
}
,
}
,
}
,
  [84] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "latin skirmisher",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 84,
  [2] = 16,
}
,
  [2] = {
  [1] = 96,
  [2] = 28,
}
,
  [3] = {
  [1] = 93,
  [2] = 15,
}
,
}
,
}
,
}
,
}
,
  [85] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "campanian cavalry",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 122,
  [2] = 52,
}
,
  [2] = {
  [1] = 121,
  [2] = 61,
}
,
  [3] = {
  [1] = 130,
  [2] = 68,
}
,
}
,
}
,
}
,
}
,
  [86] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "numidian horsemen",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 27,
  [2] = 141,
}
,
  [2] = {
  [1] = 36,
  [2] = 170,
}
,
  [3] = {
  [1] = 20,
  [2] = 136,
}
,
}
,
}
,
}
,
}
,
  [87] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "numidian warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 28,
  [2] = 128,
}
,
  [2] = {
  [1] = 33,
  [2] = 147,
}
,
  [3] = {
  [1] = 41,
  [2] = 161,
}
,
}
,
}
,
}
,
}
,
  [88] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "celtic warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 61,
  [2] = 1,
}
,
  [2] = {
  [1] = 86,
  [2] = 2,
}
,
  [3] = {
  [1] = 84,
  [2] = 16,
}
,
}
,
}
,
}
,
}
,
  [89] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "iberian warrior",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 22,
  [2] = 54,
}
,
  [2] = {
  [1] = 21,
  [2] = 63,
}
,
  [3] = {
  [1] = 20,
  [2] = 70,
}
,
}
,
}
,
}
,
}
,
  [90] = {
  ["IF"] = {
  ["randomturn"] = true,
  ["denominator"] = 8,
}
,
  ["THEN"] = {
  ["createunit"] = {
  ["unit"] = "tarentine cavalry",
  ["owner"] = "lydians",
  ["homecity"] = "none",
  ["veteran"] = "yes",
  ["locations"] = {
  [1] = {
  [1] = 160,
  [2] = 58,
}
,
  [2] = {
  [1] = 142,
  [2] = 50,
}
,
  [3] = {
  [1] = 134,
  [2] = 54,
}
,
}
,
}
,
}
,
}
,
}
