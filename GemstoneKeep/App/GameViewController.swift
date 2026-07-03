import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    override func loadView() {
        view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }
        PerformanceTuner.configure(skView)
        AudioManager.prepare()

        let scene = TitleScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscape]
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}
