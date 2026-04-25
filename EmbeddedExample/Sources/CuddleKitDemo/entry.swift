import CuddleKit
import PDFoundation
import PDUIKit
import PlaydateKit

final class Game: PlaydateGame {
    let controller: UIViewController

    init() {
        var playerString: String
        do {
            let stat = try File.stat(path: "players.kdl")
            let fileSize = stat.size
            PDReportDebug("Received file size of '\(fileSize) bytes' for players.kdl.")
            let file = try File.open(path: "players.kdl", mode: .read)
            playerString = String(reading: file, ofLength: Int(fileSize))
        } catch {
            PDReportError("Couldn't read the players.kdl file from the game's bundle.")
            self.controller = PlayerListViewController(players: [])
            return
        }

        var players: [Player]
        let serializer = KDLSerializer()
        do {
            let container = try serializer.deserialize(playerString, as: PlayerContainer.self)
            players = container.players
            PDReportDebug("Deserialized \(players.count) players from players.kdl.")
        } catch {
            PDReportError("Couldn't deserialize the players.kdl file.")
            players = []
        }
        self.controller = PlayerListViewController(players: players)
    }

    func update() -> Bool {
        controller.update()
        return true
    }
}

// MARK: - Entry Boilerplate
nonisolated(unsafe) var game: Game!

@c func eventHandler(
    pointer: UnsafeMutablePointer<PlaydateAPI>, event: System.Event, arg _: CUnsignedInt
) -> CInt {
    switch event {
    case .initialize:
        Playdate.initialize(with: pointer)
        game = Game()
        System.updateCallback = game.update
    default: game.handle(event)
    }
    return 0
}
