//! English reading forms with character ranges in the unchanged script.
use crate::follower::Token;

fn cardinal(n: u64) -> String {
    const SMALL: [&str; 20] = [
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
        "ten",
        "eleven",
        "twelve",
        "thirteen",
        "fourteen",
        "fifteen",
        "sixteen",
        "seventeen",
        "eighteen",
        "nineteen",
    ];
    const TENS: [&str; 10] = [
        "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety",
    ];
    if n < 20 {
        return SMALL[n as usize].into();
    }
    if n < 100 {
        return format!(
            "{} {}",
            TENS[(n / 10) as usize],
            if n.is_multiple_of(10) {
                String::new()
            } else {
                cardinal(n % 10)
            }
        )
        .trim()
        .into();
    }
    for (scale, name) in [
        (1_000_000_000_000, "trillion"),
        (1_000_000_000, "billion"),
        (1_000_000, "million"),
        (1000, "thousand"),
        (100, "hundred"),
    ] {
        if n >= scale {
            return format!(
                "{} {name} {}",
                cardinal(n / scale),
                if n.is_multiple_of(scale) {
                    String::new()
                } else {
                    cardinal(n % scale)
                }
            )
            .trim()
            .into();
        }
    }
    unreachable!()
}
fn ordinal(n: u64) -> String {
    let s = cardinal(n);
    let (prefix, last) = s.rsplit_once(' ').unwrap_or(("", &s));
    let last = match last {
        "one" => "first".into(),
        "two" => "second".into(),
        "three" => "third".into(),
        "five" => "fifth".into(),
        "eight" => "eighth".into(),
        "nine" => "ninth".into(),
        "twelve" => "twelfth".into(),
        s if s.ends_with('y') => format!("{}ieth", &s[..s.len() - 1]),
        s => format!("{s}th"),
    };
    format!("{prefix} {last}").trim().into()
}
fn number(s: &str) -> Option<String> {
    if s.contains(',') {
        let integer = s.split('.').next()?;
        let groups: Vec<_> = integer.split(',').collect();
        if groups[0].is_empty()
            || groups[0].len() > 3
            || groups[1..]
                .iter()
                .any(|g| g.len() != 3 || !g.bytes().all(|c| c.is_ascii_digit()))
        {
            return None;
        }
    }
    let s = s.replace(',', "");
    if let Some((whole, fraction)) = s.split_once('.') {
        if fraction.is_empty() || !fraction.bytes().all(|c| c.is_ascii_digit()) {
            return None;
        }
        let n = whole.parse::<u64>().ok()?;
        if n > 999_999_999_999 {
            return None;
        }
        return Some(format!(
            "{} point {}",
            cardinal(n),
            fraction
                .bytes()
                .map(|c| cardinal((c - b'0') as u64))
                .collect::<Vec<_>>()
                .join(" ")
        ));
    }
    for suffix in ["st", "nd", "rd", "th"] {
        if let Some(digits) = s.strip_suffix(suffix) {
            return digits
                .parse::<u64>()
                .ok()
                .filter(|n| *n <= 999_999_999_999)
                .map(ordinal);
        }
    }
    let n = s.parse::<u64>().ok()?;
    if n > 999_999_999_999 {
        return None;
    }
    if s.len() > 1 && s.starts_with('0') {
        return Some(
            s.bytes()
                .map(|c| cardinal((c - b'0') as u64))
                .collect::<Vec<_>>()
                .join(" "),
        );
    }
    Some(cardinal(n))
}
const MONTHS: [&str; 12] = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
];
fn date(s: &str) -> Option<String> {
    let parts = s.split(['/', '-']).collect::<Vec<_>>();
    if parts.len() != 3 {
        return None;
    }
    let values = parts
        .iter()
        .map(|p| p.parse::<u64>())
        .collect::<Result<Vec<_>, _>>()
        .ok()?;
    let (d, m, y) = if parts[0].len() == 4 {
        (values[2], values[1], values[0])
    } else {
        (values[0], values[1], values[2])
    };
    if !(1..=12).contains(&m) || !(1000..=9999).contains(&y) {
        return None;
    }
    let leap = y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);
    let max = [
        31,
        if leap { 29 } else { 28 },
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
    ][m as usize - 1];
    if d == 0 || d > max {
        return None;
    }
    Some(format!(
        "{} {} {}",
        ordinal(d),
        MONTHS[m as usize - 1],
        cardinal(y)
    ))
}
fn reading(raw: &str) -> String {
    let s = raw.to_lowercase();
    if let Some(n) = s.strip_prefix('-').and_then(number) {
        return format!("minus {n}");
    }
    if let Some(d) = date(&s) {
        return d;
    }
    let currency = [
        ('£', "pound", "pence"),
        ('$', "dollar", "cents"),
        ('€', "euro", "cents"),
    ];
    for (symbol, unit, minor) in currency {
        if let Some(amount) = s.strip_prefix(symbol) {
            let clean = amount.replace(',', "");
            if let Some((a, b)) = clean.split_once('.') {
                if b.len() == 2 && b.bytes().all(|c| c.is_ascii_digit()) {
                    if let (Some(a_words), Ok(cents)) = (number(a), b.parse::<u64>()) {
                        return format!(
                            "{a_words} {unit}{} {}",
                            if a == "1" { "" } else { "s" },
                            if cents == 0 {
                                String::new()
                            } else {
                                format!(
                                    "{} {}",
                                    cardinal(cents),
                                    if cents == 1 {
                                        if symbol == '£' {
                                            "penny"
                                        } else {
                                            "cent"
                                        }
                                    } else {
                                        minor
                                    }
                                )
                            }
                        );
                    }
                }
            } else if let Some(n) = number(amount) {
                return format!("{n} {unit}{}", if clean == "1" { "" } else { "s" });
            }
        }
    }
    if let Some(n) = s.strip_suffix('%').and_then(number) {
        return format!("{n} percent");
    }
    if let Some(n) = number(&s) {
        return n;
    }
    let compact = s.replace('.', "");
    let expansion = match compact.as_str() {
        "dr" => Some("doctor"),
        "mr" => Some("mister"),
        "mrs" => Some("missus"),
        "ms" => Some("miz"),
        "prof" => Some("professor"),
        "etc" => Some("et cetera"),
        "eg" => Some("for example"),
        "ie" => Some("that is"),
        "jan" => Some("january"),
        "feb" => Some("february"),
        "mar" => Some("march"),
        "apr" => Some("april"),
        "jun" => Some("june"),
        "jul" => Some("july"),
        "aug" => Some("august"),
        "sep" | "sept" => Some("september"),
        "oct" => Some("october"),
        "nov" => Some("november"),
        "dec" => Some("december"),
        "bbc" => Some("b b c"),
        "nhs" => Some("n h s"),
        "uk" => Some("u k"),
        "usa" => Some("u s a"),
        "ceo" => Some("c e o"),
        "ai" => Some("a i"),
        "fbi" => Some("f b i"),
        "kg" => Some("kilograms"),
        "km" => Some("kilometres"),
        "cm" => Some("centimetres"),
        _ => None,
    };
    expansion.unwrap_or(&s).to_owned()
}

/// Longest matching alias wins. Each line is `written phrase = spoken phrase`.
/// Aliases apply only to the script, and never recursively.
fn lex(text: &str) -> Vec<Token> {
    let chars: Vec<char> = text.chars().collect();
    let mut raw = Vec::new();
    let mut i = 0;
    while i < chars.len() {
        if !chars[i].is_alphanumeric()
            && !['£', '$', '€'].contains(&chars[i])
            && !(chars[i] == '-' && chars.get(i + 1).is_some_and(char::is_ascii_digit))
        {
            i += 1;
            continue;
        }
        let start = i;
        i += 1;
        while i < chars.len() {
            let c = chars[i];
            if c.is_alphanumeric()
                || ['\'', '’'].contains(&c)
                || (['.', ',', '/', '-'].contains(&c)
                    && i + 1 < chars.len()
                    && chars[i - 1].is_ascii_digit()
                    && chars[i + 1].is_ascii_digit())
                || (c == '.' && i + 1 < chars.len() && chars[i + 1].is_alphabetic())
                || c == '%'
            {
                i += 1;
            } else {
                break;
            }
        }
        raw.push(Token {
            text: chars[start..i].iter().collect(),
            character: start,
            end: i,
        });
    }
    raw
}
pub fn tokens(text: &str, aliases: &str) -> Vec<Token> {
    let raw = lex(text);
    let mut rules: Vec<_> = aliases
        .lines()
        .filter_map(|l| l.split_once('='))
        .filter_map(|(a, b)| {
            let key = lex(a);
            if key.is_empty() || b.trim().is_empty() {
                None
            } else {
                Some((key, b.trim()))
            }
        })
        .collect();
    rules.sort_by_key(|(a, _)| std::cmp::Reverse(a.len()));
    let mut expanded = Vec::new();
    let mut index = 0;
    while index < raw.len() {
        let mut count = 1;
        let mut phrase = reading(&raw[index].text);
        // Written day numbers beside a month are normally spoken as ordinals.
        if let Ok(day) = raw[index].text.parse::<u64>() {
            let beside_month = raw
                .get(index + 1)
                .is_some_and(|t| MONTHS.contains(&reading(&t.text).as_str()))
                || index
                    .checked_sub(1)
                    .is_some_and(|i| MONTHS.contains(&reading(&raw[i].text).as_str()));
            if (1..=31).contains(&day) && beside_month {
                phrase = ordinal(day);
            }
        }
        let mut alias = false;
        for (key, value) in &rules {
            if index + key.len() <= raw.len()
                && key
                    .iter()
                    .zip(&raw[index..])
                    .all(|(a, b)| a.text.to_lowercase() == b.text.to_lowercase())
            {
                count = key.len();
                phrase = value.to_string();
                alias = true;
                break;
            }
        }
        for word in if alias {
            tokens(&phrase, "")
        } else {
            crate::follower::tokenize(&phrase)
        } {
            expanded.push(Token {
                text: word.text,
                character: raw[index].character,
                end: raw[index + count - 1].end,
            });
        }
        index += count;
    }
    // Normalize paired year readings ("nineteen ninety nine", "twenty twenty six")
    // to the same form as written years, retaining the full original range.
    let mut result = Vec::new();
    let mut i = 0;
    while i < expanded.len() {
        let t = &expanded[i];
        let century = match t.text.as_str() {
            "nineteen" => 1900,
            "twenty" => 2000,
            _ => 0,
        };
        let tens = expanded.get(i + 1).and_then(|t| match t.text.as_str() {
            "twenty" => Some(20),
            "thirty" => Some(30),
            "forty" => Some(40),
            "fifty" => Some(50),
            "sixty" => Some(60),
            "seventy" => Some(70),
            "eighty" => Some(80),
            "ninety" => Some(90),
            _ => None,
        });
        if let Some(tens) = tens.filter(|_| century != 0) {
            let unit = expanded
                .get(i + 2)
                .and_then(|t| (1..10).find(|n| cardinal(*n) == t.text));
            let count = if unit.is_some() { 3 } else { 2 };
            for word in cardinal(century + tens + unit.unwrap_or(0)).split_whitespace() {
                result.push(Token {
                    text: word.into(),
                    character: t.character,
                    end: expanded[i + count - 1].end,
                });
            }
            i += count;
        } else {
            // Optional connecting words are not alignment evidence.
            if !["and", "the", "of"].contains(&t.text.as_str()) {
                result.push(t.clone());
            }
            i += 1;
        }
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;
    fn words(s: &str) -> Vec<String> {
        tokens(s, "").into_iter().map(|t| t.text).collect()
    }
    #[test]
    fn equivalent_readings() {
        for (a, b) in [
            ("£25", "twenty-five pounds"),
            ("£1.05", "one pound and five pence"),
            (
                "1,204.50",
                "one thousand two hundred and four point five zero",
            ),
            ("25%", "twenty five percent"),
            ("03/11/2026", "the third of November twenty twenty six"),
            ("2026-11-03", "third November two thousand twenty six"),
            ("Dr. Jones at the BBC", "doctor Jones at the b b c"),
            ("21st", "twenty first"),
            ("3 Nov 2026", "third november twenty twenty six"),
            ("November 3, 2026", "November third two thousand twenty six"),
            ("-25", "minus twenty five"),
        ] {
            assert_eq!(words(a), words(b), "{a}");
        }
    }
    #[test]
    fn alias_ranges_and_invalid_dates() {
        let ts = tokens("Élodie meets Siobhan today", "Siobhan = shiv on");
        assert_eq!(ts[2].text, "shiv");
        assert_eq!(ts[3].text, "on");
        assert_eq!((ts[2].character, ts[3].end), (13, 20));
        assert!(date("31/02/2026").is_none());
        assert!(date("29/02/2024").is_some());
    }
}
