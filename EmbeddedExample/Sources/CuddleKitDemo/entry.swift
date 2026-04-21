import CuddleKit
import PlaydateKit

final class Game: PlaydateGame {
    let players: [Player]

    init() {
        let players =
            """
            player "Paul" character="thorax" stat=12
            player "Zack" character="pharynx" stat=13
            player "presentfox" character="chrysalis" stat=77
            """

        let serializer = KDLSerializer()
        do {
            let players = try serializer.deserializeArray(players, containing: Player.self)
            self.players = players
        } catch {
            print("Couldn't load players!")
            self.players = []
        }
    }

    func update() -> Bool {
        System.drawFPS()
        Graphics.clear(color: .white)
        var yOffset = 16
        for player in players {
            Graphics
                .drawText(
                    "Player: \(player.name) (as \(player.character.rawValue), \(player.initialStat))",
                    at: Point(x: 16, y: yOffset)
                )
            yOffset += 24
        }
        return true
    }
}

// MARK: - Entry Boilerplate
nonisolated(unsafe) var game: Game!

@c func eventHandler(pointer: UnsafeMutablePointer<PlaydateAPI>, event: System.Event, arg _: CUnsignedInt) -> CInt {
    switch event {
    case .initialize:
        Playdate.initialize(with: pointer)
        game = Game()
        System.updateCallback = game.update
    default: game.handle(event)
    }
    return 0
}
