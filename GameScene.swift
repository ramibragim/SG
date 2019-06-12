
import SpriteKit
import GameplayKit

struct CollisionCategories {
	
	static let Snake: UInt32 = 0x1 << 0
	
	static let SnakeHead: UInt32 = 0x1 << 1
	
	static let Apple: UInt32 = 0x1 << 2
	
	static let EdgeBody: UInt32 = 0x1 << 3
}

class GameScene: SKScene {
	
	var snake: Snake?
	
	override func didMove(to view: SKView) {

		physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		physicsWorld.contactDelegate = self
		
		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
		physicsBody?.allowsRotation = false
		view.showsPhysics = true
		
		physicsBody?.categoryBitMask = CollisionCategories.EdgeBody
		physicsBody?.collisionBitMask = CollisionCategories.Snake | CollisionCategories.SnakeHead
		
		let counterClockwiseButton = SKShapeNode()
		
		counterClockwiseButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 50, height: 50)).cgPath
		counterClockwiseButton.position = CGPoint(x: view.scene!.frame.minX + 30, y: view.scene!.frame.minY + 30)
		
		counterClockwiseButton.fillColor = UIColor.gray
		counterClockwiseButton.strokeColor = UIColor.gray
		
		counterClockwiseButton.lineWidth = 10
		counterClockwiseButton.name = "counterClockwiseButton"
		
		self.addChild(counterClockwiseButton)
		
		let clockwiseButton = SKShapeNode()
		
		clockwiseButton.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 50, height: 50)).cgPath
		clockwiseButton.position = CGPoint(x: view.scene!.frame.maxX - 80, y: view.scene!.frame.minY + 30)
		
		clockwiseButton.fillColor = UIColor.gray
		clockwiseButton.strokeColor = UIColor.gray
		
		clockwiseButton.lineWidth = 10
		clockwiseButton.name = "clockwiseButton"
		
		self.addChild(clockwiseButton)
		
		createApple()
		createSnake(&snake)
		
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let touchLocation = touch.location(in: self)
			
			guard let touchedNode = self.atPoint(touchLocation) as? SKShapeNode,
				touchedNode.name == "counterClockwiseButton" || touchedNode.name == "clockwiseButton" else { return }
			
			touchedNode.fillColor = .green
			
			if touchedNode.name == "counterClockwiseButton" {
				snake!.moveCounterClockwise()
			} else if touchedNode.name == "clockwiseButton" {
				snake!.moveClockwise()
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let touchLocation = touch.location(in: self)
			
			guard let touchedNode = self.atPoint(touchLocation) as? SKShapeNode,
				touchedNode.name == "counterClockwiseButton" || touchedNode.name == "clockwiseButton" else { return }
			
			touchedNode.fillColor = .gray
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		snake!.move()
	}
	
	func createApple() {
		
		let randX = CGFloat(arc4random_uniform(UInt32(view!.scene!.frame.maxX - 15)) + 1)
		let randY = CGFloat(arc4random_uniform(UInt32(view!.scene!.frame.maxY - 15)) + 1)
		
		let apple = Apple(position: CGPoint(x: randX, y: randY))
		addChild(apple)
	}
	// Добавляем змейку на экран в центре
	func createSnake(_ snake: inout Snake?){
		snake = Snake(atPoint: CGPoint(x: view?.scene!.frame.midX ?? 20, y: view?.scene!.frame.midY ?? 20))
		addChild(snake!)
	}
	// удаляем и пересоздаем змейку
	func removeSnake() {
		self.snake?.removeFromParent()
		self.createSnake(&self.snake)
	}
	// показываем сообщение
	func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "Ok", style: .cancel) { (_) in
			self.removeSnake()
		}
		alert.addAction(ok)
		view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
	}
}

extension GameScene: SKPhysicsContactDelegate {
	
	func didBegin(_ contact: SKPhysicsContact) {
		
		let bodyes = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		let collisionObject = bodyes ^ CollisionCategories.SnakeHead
		
		switch collisionObject {
		case CollisionCategories.Apple:
			let apple = contact.bodyA.node is Apple ? contact.bodyA.node : contact.bodyB.node
			snake?.addBodyPart()
			apple?.removeFromParent()
			createApple()
			
		// проверяем, что это стенка экрана
		case CollisionCategories.EdgeBody:
			showAlert(title: "Game Over", message: "Reload?")
			
		default:
			break
		}
	}
	
}
