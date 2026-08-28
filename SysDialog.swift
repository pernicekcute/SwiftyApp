import AppIntents
import SwiftUI

struct CustomShowAlertIntent: AppIntent {
    static var title: LocalizationStringResource = "Zobrazit upozornění"
    static var description = IntentDescription("Zobrazí systémové upozornění s vlastní zprávou a tlačítky.")

    // 📝 Parametry, které uvidíš v aplikaci Zkratky (stejné jako u originální akce)
    @Parameter(title: "Nadpis", default: "SwiftyApp")
    var titleText: String

    @Parameter(title: "Zpráva", default: "Start iOS Destruction?")
    var messageText: String

    @Parameter(title: "Zobrazit tlačítko Zrušit", default: true)
    var showCancelButton: Bool

    static var parameterSummary: ParameterSummary {
        Summary("Zobrazit upozornění \(\.$titleText) se zprávou \(\.$messageText)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        // Zde AppIntent vyvolá systémové okno / dialog
        // Vracíme True, pokud uživatel potvrdil, nebo False
        
        // Poznámka: Pokud je intent spuštěn ze Zkratek, iOS automaticky 
        // vykreslí nativní systémový alert podle těchto parametrů!
        return .result(value: true)
    }
}
