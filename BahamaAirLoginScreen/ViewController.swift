import UIKit

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

func tintBackgroundColor(layer: CALayer, toColor: UIColor) {
  let tint = CABasicAnimation(keyPath: "backgroundColor")
  tint.fromValue = layer.backgroundColor
  tint.toValue = toColor.cgColor
  tint.duration = 0.5
  layer.add(tint, forKey: nil)
  layer.backgroundColor = toColor.cgColor
}

func roundCorners(layer: CALayer, toRadius: CGFloat) {
  let round = CABasicAnimation(keyPath: "cornerRadius")
  round.fromValue = layer.cornerRadius
  round.toValue = toRadius
  round.duration = 0.5
  layer.add(round, forKey: nil)
  layer.cornerRadius = toRadius
}

class ViewController: UIViewController {

  // MARK: IB outlets

  @IBOutlet var loginButton: UIButton!
  @IBOutlet var heading: UILabel!
  @IBOutlet var username: UITextField!
  @IBOutlet var password: UITextField!

  @IBOutlet var cloud1: UIImageView!
  @IBOutlet var cloud2: UIImageView!
  @IBOutlet var cloud3: UIImageView!
  @IBOutlet var cloud4: UIImageView!

  // MARK: further UI

  let spinner = UIActivityIndicatorView(style: .whiteLarge)
  let status = UIImageView(image: UIImage(named: "banner"))
  let label = UILabel()
  let messages = ["Connecting ...", "Authorizing ...", "Sending credentials ...", "Failed"]

  var statusPosition = CGPoint.zero
  let info = UILabel()

  // MARK: view controller methods

  override func viewDidLoad() {
    super.viewDidLoad()

    //set up the UI
    info.frame = CGRect(x: 0.0,
                        y: loginButton.center.y + 60.0,
                        width: view.frame.size.width,
                        height: 30)
    info.backgroundColor = .clear
    info.font = UIFont(name: "HelveticaNeue", size: 12.0)
    info.textAlignment = .center
    info.textColor = .white
    info.text = "Tap on a field and enter username and password"
    view.insertSubview(info, belowSubview: loginButton)

    loginButton.layer.cornerRadius = 8.0
    loginButton.layer.masksToBounds = true

    spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
    spinner.startAnimating()
    spinner.alpha = 0.0
    loginButton.addSubview(spinner)

    status.isHidden = true
    status.center = loginButton.center
    view.addSubview(status)

    label.frame = CGRect(x: 0.0, y: 0.0, width: status.frame.size.width, height: status.frame.size.height)
    label.font = UIFont(name: "HelveticaNeue", size: 18.0)
    label.textColor = UIColor(red: 0.89, green: 0.38, blue: 0.0, alpha: 1.0)
    label.textAlignment = .center
    status.addSubview(label)

    statusPosition = status.center
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let flyRight = CABasicAnimation(keyPath: "position.x")
    flyRight.delegate = self
    flyRight.setValue("form", forKey: "name")
    flyRight.fromValue = -view.bounds.size.width/2
    flyRight.toValue = view.bounds.size.width/2
    flyRight.fillMode = .both

    flyRight.duration = 0.5
    flyRight.setValue(heading.layer, forKey: "layer")
    heading.layer.add(flyRight, forKey: nil)
    flyRight.beginTime = CACurrentMediaTime() + 0.3
    flyRight.setValue(username.layer, forKey: "layer")
    username.layer.add(flyRight, forKey: nil)
    username.layer.position.x = view.bounds.size.width/2
    flyRight.beginTime = CACurrentMediaTime() + 0.4
    flyRight.setValue(password.layer, forKey: "layer")
    password.layer.add(flyRight, forKey: nil)
    password.layer.position.x = view.bounds.size.width/2


  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    username.delegate = self
    password.delegate = self

    let fadeIn = CABasicAnimation(keyPath: "opacity")
    fadeIn.fromValue = 0.0
    fadeIn.toValue = 1.0
    fadeIn.duration = 0.5
    fadeIn.fillMode = .backwards
    fadeIn.beginTime = CACurrentMediaTime() + 0.5
    cloud1.layer.add(fadeIn, forKey: nil)

    fadeIn.beginTime = CACurrentMediaTime() + 0.7
    cloud2.layer.add(fadeIn, forKey: nil)

    fadeIn.beginTime = CACurrentMediaTime() + 0.9
    cloud3.layer.add(fadeIn, forKey: nil)

    fadeIn.beginTime = CACurrentMediaTime() + 1.1
    cloud4.layer.add(fadeIn, forKey: nil)

    let groupAnimation = CAAnimationGroup()
    groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
    groupAnimation.beginTime = CACurrentMediaTime() + 0.5
    groupAnimation.duration = 0.5
    groupAnimation.fillMode = .backwards
    let scaleDown = CABasicAnimation(keyPath: "transform.scale")
    scaleDown.fromValue = 3.5
    scaleDown.toValue = 1.0
    let rotate = CABasicAnimation(keyPath: "transform.rotation")
    rotate.fromValue = .pi / 4.0
    rotate.toValue = 0.0
    let fade = CABasicAnimation(keyPath: "opacity")
    fade.fromValue = 0.0
    fade.toValue = 1.0
    groupAnimation.animations = [scaleDown, rotate, fade]
    loginButton.layer.add(groupAnimation, forKey: nil)

    animateCloud(cloud1)
    animateCloud(cloud2)
    animateCloud(cloud3)
    animateCloud(cloud4)

    let flyLeft = CABasicAnimation(keyPath: "position.x")
    flyLeft.repeatCount = 2.5
    flyLeft.speed = 1.2
    flyLeft.autoreverses = true
    flyLeft.fromValue = info.layer.position.x +
    view.frame.size.width
    flyLeft.toValue = info.layer.position.x
    flyLeft.duration = 5.0
    info.layer.add(flyLeft, forKey: "infoappear")

    let fadeLabelIn = CABasicAnimation(keyPath: "opacity")
    fadeLabelIn.fromValue = 0.2
    fadeLabelIn.toValue = 1.0
    fadeLabelIn.duration = 4.5
    info.layer.add(fadeLabelIn, forKey: "fadein")
  }

  func showMessage(index: Int) {
    label.text = messages[index]

    UIView.transition(with: status, duration: 0.33,
      options: [.curveEaseOut, .transitionFlipFromBottom],
      animations: {
        self.status.isHidden = false
      },
      completion: {_ in
        //transition completion
        delay(seconds: 2.0) {
          if index < self.messages.count-1 {
            self.removeMessage(index: index)
          } else {
            //reset form
            self.resetForm()
          }
        }
      }
    )
  }

  func removeMessage(index: Int) {

    UIView.animate(withDuration: 0.33, delay: 0.0,
      animations: {
        self.status.center.x += self.view.frame.size.width
      },
      completion: {_ in
        self.status.isHidden = true
        self.status.center = self.statusPosition

        self.showMessage(index: index+1)
      }
    )
  }

  func resetForm() {
    UIView.transition(with: status, duration: 0.2, options: .transitionFlipFromTop,
      animations: {
        self.status.isHidden = true
        self.status.center = self.statusPosition
      },
      completion: { _ in
        let tintColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
        tintBackgroundColor(layer: self.loginButton.layer, toColor: tintColor)
        roundCorners(layer: self.loginButton.layer, toRadius: 10.0)
      })

    UIView.animate(withDuration: 0.2, delay: 0.0,
      animations: {
        self.spinner.center = CGPoint(x: -20.0, y: 16.0)
        self.spinner.alpha = 0.0
        self.loginButton.bounds.size.width -= 80.0
        self.loginButton.center.y -= 60.0
      },
      completion: nil)
  }

  // MARK: further methods

  @IBAction func login() {
    view.endEditing(true)

    UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.2,
      initialSpringVelocity: 0.0,
      animations: {
        self.loginButton.bounds.size.width += 80.0
      },
      completion: {_ in
        self.showMessage(index: 0)
      }
    )

    UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.0,
      animations: {
        self.loginButton.center.y += 60.0
        self.spinner.center = CGPoint(x: 40.0, y: self.loginButton.frame.size.height/2)
        self.spinner.alpha = 1.0
      },
      completion: nil
    )

    let tintColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
    tintBackgroundColor(layer: loginButton.layer, toColor: tintColor)
    roundCorners(layer: loginButton.layer, toRadius: 25.0)
  }

  func animateCloud(_ cloud: UIImageView) {
    let cloudSpeed = 60.0 / view.frame.size.width
    let duration = (view.frame.size.width - cloud.frame.origin.x) * cloudSpeed
    UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: .curveLinear,
      animations: {
        cloud.frame.origin.x = self.view.frame.size.width
      },
      completion: {_ in
        cloud.frame.origin.x = -cloud.frame.size.width
        self.animateCloud(cloud)
      }
    )
  }

  // MARK: UITextFieldDelegate

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let nextField = (textField === username) ? password : username
    nextField?.becomeFirstResponder()
    return true
  }

}

extension ViewController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard let name = anim.value(forKey: "name") as? String else {
      return
    }

    if name == "form" {
      let layer = anim.value(forKey: "layer") as? CALayer
      anim.setValue(nil, forKey: "layer")
      let pulse = CASpringAnimation(keyPath: "transform.scale")
      pulse.damping = 7.5
      pulse.fromValue = 1.25
      pulse.toValue = 1.0
      pulse.duration = pulse.settlingDuration
      layer?.add(pulse, forKey: nil)
    }
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    guard let _ = info.layer.animationKeys()else {
      return
    }
    info.layer.removeAnimation(forKey: "infoappear")
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let text = textField.text else { return }
    if text.count < 5 {
      let jump = CASpringAnimation(keyPath: "position.y")
      jump.initialVelocity = 100.0
      jump.mass = 10.0
      jump.stiffness = 1500.0
      jump.damping = 50.0
      jump.fromValue = textField.layer.position.y + 1.0
      jump.toValue = textField.layer.position.y
      jump.duration = jump.settlingDuration
      textField.layer.borderWidth = 3.0
      textField.layer.borderColor = UIColor.clear.cgColor
      textField.layer.cornerRadius = 5
      textField.layer.add(jump, forKey: nil)

      let flash = CASpringAnimation(keyPath: "borderColor")
      flash.damping = 2.0
      flash.stiffness = 200.0
      flash.fromValue = UIColor(red: 1.0, green: 0.27, blue: 0.0,
      alpha: 1.0).cgColor
      flash.toValue = UIColor.white.cgColor
      flash.duration = flash.settlingDuration
      textField.layer.add(flash, forKey: nil)
  } }
}
