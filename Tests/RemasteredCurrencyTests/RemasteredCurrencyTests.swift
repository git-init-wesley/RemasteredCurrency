import XCTest
import RemasteredJson
@testable import RemasteredCurrency

struct RemasteredCurrencyNew: Identifiable, Codable {
    internal var id: UUID? = UUID()
    let code: String
    let rate: Float
}

struct RemasteredCurrencyOld: Identifiable, Codable {
    internal var id: UUID? = UUID()
    let rates: [String: Float]
}


final class RemasteredCurrencyTests: XCTestCase {


    func resolveNewDataFromOlderData() throws {
        self.expectation(description: "resolveNewDataFromOlderData")
        try RemasteredJson<RemasteredCurrencyOld>().decode(externalUrl: RemasteredCurrencyEnvTests.LATEST_URL) { (result: Result<RemasteredCurrencyOld, Error>) in
            switch result {
            case .success(let currenciesOld):
                var strings: [String] = [], currencies: [RemasteredCurrencyNew] = []
                currenciesOld.rates.forEach { (key: String, value: Float) in
                    strings.append(key)
                    currencies.append(.init(code: key, rate: value))
                }
                do {
                    try RemasteredJson<[RemasteredCurrencyNew]>().encode(currencies, completion: { (result: Result<Data, Error>) in
                        switch result {
                        case .success(let data):
                            print("----------\nNew Json:\n\(String(data: data, encoding: .utf8) ?? "N/A")\n----------")
                        case .failure(let error):
                            print("----------\nNew Json:\n\(error.localizedDescription)\n----------")
                        }
                    })
                } catch {
                    print(error.localizedDescription)
                }
                print("----------\nNew currency?\n\(strings.count == Currency.allCases.count ? "No" : "Yes")\n----------")
                print("----------\nCurrencies:\n\(strings.sorted())\n----------")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        self.waitForExpectations(timeout: 5000, handler: nil)
    }

    func testExample() throws {
        let resolve: Bool = false
        if resolve {
            do {
                try resolveNewDataFromOlderData()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            do {
                self.expectation(description: "init")
                try RemasteredCurrencyApp(RemasteredCurrencyApp.Options("https://raw.githubusercontent.com/kanekireal/wesley-dev.codes/main/remasteredcurrency/remastered_currencies.json"))
                waitForExpectations(timeout: 5) { error in
                    do {
                        print("----------")
                        let currencies: [RemasteredCurrency] = try RemasteredCurrencyStore.getCurrencies()

                        currencies.forEach { (currency: RemasteredCurrency) in
                            print("\(currency.getCode()) : \(currency.getRate())")
                        }
                        print("----------")

                        let amount: Float = 5
                        let currency1: Currency = Currency.PAB
                        let currency2: Currency = Currency.KES

                        print("Convert:")
                        print("\(amount) \(currency1.rawValue) to \(currency2.rawValue)")
                        print("= \(try currency1.convert(amount, currencyEnd: currency2)) \(currency2.rawValue)")
                        print("----------")
                    } catch {
                        print(error.localizedDescription)
                        print("----------")
                    }
                }
            } catch {
                print(error.localizedDescription)
                print("----------")
            }
        }
    }
}
