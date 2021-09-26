//
//  Conçu avec ♡ par Levasseur Wesley.
//  © Copyright 2021. Tous droits réservés.
//
//  Création datant du 27/05/2021.
//

import Foundation
import RemasteredJson

public enum Currency: String, CaseIterable {
    case AED, AFN, ALL, AMD, ANG, AOA, ARS, AUD, AWG, AZN, BAM, BBD, BDT, BGN, BHD, BIF, BMD, BND, BOB, BRL, BSD, BTC, BTN, BWP, BYN, BYR, BZD, CAD, CDF, CHF, CLF, CLP, CNY, COP, CRC, CUC, CUP, CVE, CZK, DJF, DKK, DOP, DZD, EGP, ERN, ETB, EUR, FJD, FKP, GBP, GEL, GGP, GHS, GIP, GMD, GNF, GTQ, GYD, HKD, HNL, HRK, HTG, HUF, IDR, ILS, IMP, INR, IQD, IRR, ISK, JEP, JMD, JOD, JPY, KES, KGS, KHR, KMF, KPW, KRW, KWD, KYD, KZT, LAK, LBP, LKR, LRD, LSL, LTL, LVL, LYD, MAD, MDL, MGA, MKD, MMK, MNT, MOP, MRO, MUR, MVR, MWK, MXN, MYR, MZN, NAD, NGN, NIO, NOK, NPR, NZD, OMR, PAB, PEN, PGK, PHP, PKR, PLN, PYG, QAR, RON, RSD, RUB, RWF, SAR, SBD, SCR, SDG, SEK, SGD, SHP, SLL, SOS, SRD, STD, SVC, SYP, SZL, THB, TJS, TMT, TND, TOP, TRY, TTD, TWD, TZS, UAH, UGX, USD, UYU, UZS, VEF, VND, VUV, WST, XAF, XAG, XAU, XCD, XDR, XOF, XPF, YER, ZAR, ZMK, ZMW, ZWL

    public func getRemasteredCurrency() throws -> RemasteredCurrency? {
        try RemasteredCurrencyStore.getCurrencyFromCode(self.rawValue)
    }

    public func convert(_ amount: Float, currencyEnd: Currency) throws -> Float {
        try Currency.convert(amount, currencyStart: self, currencyEnd: currencyEnd)
    }

    public static func convert(_ amount: Float, currencyStart: Currency, currencyEnd: Currency) throws -> Float {
        try currencyEnd.getRemasteredCurrency()!.getRate() / currencyStart.getRemasteredCurrency()!.getRate() * amount
    }
}

public struct RemasteredCurrency: Identifiable, Codable {
    public var id: UUID? = UUID()

    private let code: String

    public func getCode() -> String {
        self.code
    }

    private let rate: Float

    public func getRate() -> Float {
        self.rate
    }
}

public class RemasteredCurrencyApp {

    internal static var isExternal: Bool = false
    internal static var externalUrl: String = ""

    public init(_ options: Options = Options(.none)) throws {
        RemasteredCurrencyApp.isExternal = options.externalUrl != nil
        RemasteredCurrencyApp.externalUrl = options.externalUrl ?? ""
        try RemasteredCurrencyStore.shared()
    }

    public class Options {

        internal var externalUrl: String?

        public init(_ externalUrl: String?) {
            self.externalUrl = externalUrl
        }
    }
}

public class RemasteredCurrencyStore {

    //MARK: Shares
    internal static var share: RemasteredCurrencyStore?

    internal static func shared() throws -> RemasteredCurrencyStore {
        if RemasteredCurrencyStore.share == nil {
            RemasteredCurrencyStore.share = try RemasteredCurrencyStore()
        }
        return RemasteredCurrencyStore.share!
    }

    internal init() throws {
        let currencies: [RemasteredCurrency] = try RemasteredJson<[RemasteredCurrency]>().decode(localUrl: Bundle.module.url(forResource: "remastered_currencies", withExtension: "json"))
        self.currencies = currencies
        self.currenciesCode = currencies.map {
            $0.getCode()
        }
        if (RemasteredCurrencyApp.isExternal) {
            try RemasteredJson<[RemasteredCurrency]>().decode(externalUrl: RemasteredCurrencyApp.externalUrl) { (result: Result<[RemasteredCurrency], Error>) in
                switch result {
                case .success(let currencies):
                    self.currencies = currencies
                    self.currenciesCode = currencies.map {
                        $0.getCode()
                    }
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    public static func getCurrencyFromCode(_ code: String) throws -> RemasteredCurrency? {
        try RemasteredCurrencyStore.shared().currencies.filter {
            $0.getCode().lowercased() == code.lowercased()
        }.first
    }

    private var currencies: [RemasteredCurrency] = []

    public static func getCurrencies() throws -> [RemasteredCurrency] {
        try RemasteredCurrencyStore.shared().currencies
    }

    private var currenciesCode: [String] = []

    public static func getCurrenciesCode() throws -> [String] {
        try RemasteredCurrencyStore.shared().currenciesCode
    }

}
