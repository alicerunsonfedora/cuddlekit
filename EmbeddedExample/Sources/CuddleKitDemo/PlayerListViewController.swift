import PDUIKit
import PlaydateKit

class PlayerListViewController: UIViewController {
    var players: [Player] {
        didSet { playerView.players = players }
    }
    private var playerView: PlayerListView

    init(players: [Player]) {
        self.players = players
        self.playerView = PlayerListView(players: players)
        super.init()

        view.addSubview(playerView)
    }
}

class PlayerListView: UIView {
    private enum Constants {
        static let labelPadding: Float = 16.0
    }
    var players: [Player]

    init(players: [Player], frame: UIRect = .zero) {
        self.players = players
        super.init(frame: frame)
        setupView()
    }

    private func didChangePlayers() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        setupView()
        setNeedsDraw()
    }

    private func setupView() {
        var yOffset: Float = 16.0
        let titleLabel = UILabel(
            text: "Active Players", frame: .inferredContentSize(at: Point(x: 16, y: 16)))
        titleLabel.isMultiline = false
        titleLabel.font = .preferredSystemFont(for: .title)
        addSubview(titleLabel)
        yOffset += titleLabel.contentIntrinsicSize.height + Constants.labelPadding

        if players.isEmpty {
            let label = UILabel(
                text: "No players available.",
                frame: .inferredContentSize(at: Point(x: 16, y: yOffset)))
            label.isMultiline = false
            addSubview(label)
            setNeedsDraw()
            return
        }

        for player in players {
            createLabelGroup(for: player, at: &yOffset)
        }
        setNeedsDraw()
    }

    private func createLabelGroup(for player: Player, at yOffset: inout Float) {
        let label = UILabel(
            text:
                "\(player.name) [\(player.initialStat) | \(player.character.displayName)]",
            frame: .inferredContentSize(at: Point(x: 16.0, y: yOffset)))
        label.isMultiline = false
        addSubview(label)

        if !player.hasDisplayName {
            yOffset += label.contentIntrinsicSize.height + Constants.labelPadding
            return
        }

        yOffset += label.contentIntrinsicSize.height + (Constants.labelPadding / 2)
        let sublabel = UILabel(
            text: "(\(player.username))",
            frame: .inferredContentSize(at: Point(x: 16.0, y: yOffset)))
        sublabel.isMultiline = false
        sublabel.font = .preferredSystemFont(for: .caption)
        addSubview(sublabel)
        yOffset += sublabel.contentIntrinsicSize.height + Constants.labelPadding
    }
}
