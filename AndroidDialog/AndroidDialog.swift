
import Foundation
import UIKit
import JustLayout

fileprivate struct PrivateValues {
    fileprivate static var queue: DispatchQueue = DispatchQueue.init(label: "cn.meniny.AndroidDialog.queue")
    fileprivate static var semaphore: DispatchSemaphore = DispatchSemaphore.init(value: 1)
}

public class AndroidDialog: UIView {
    public private(set) var coverView: UIView                     = UIView.init()
    public private(set) var dialogView: AndroidDialog.ContextView = AndroidDialog.ContextView.init()
    
    public var title: String = "Alert"
    public var message: String?
    public var positive: String? = "Done"
    public var negative: String?
    
    public var positiveAction: ((AndroidDialog) -> Void)?
    public var negativeAction: ((AndroidDialog) -> Void)?
    
    @discardableResult
    public func setTitle(_ text: String) -> Self {
        self.title = text
        return self
    }
    
    @discardableResult
    public func setMessage(_ text: String) -> Self {
        self.message = text
        return self
    }
    
    @discardableResult
    public func setPositiveButton(_ text: String, _ action: ((AndroidDialog) -> Void)? = nil) -> Self {
        self.positive = text
        self.positiveAction = action
        return self
    }
    
    @discardableResult
    public func setNegativeButton(_ text: String, _ action: ((AndroidDialog) -> Void)? = nil) -> Self {
        self.negative = text
        self.negativeAction = action
        return self
    }
    
    public enum QueueType: Equatable {
        case `default`
        case custom(DispatchQueue, DispatchSemaphore)
        case none
        
        public var queue: DispatchQueue {
            switch self {
            case .none:
                return .main
            case .custom(let q, _):
                return q
            default:
                return PrivateValues.queue
            }
        }
        
        public var semaphore: DispatchSemaphore? {
            switch self {
            case .none:
                return nil
            case .custom(_, let s):
                return s
            default:
                return PrivateValues.semaphore
            }
        }
    }
    
    public private(set) var queueType: AndroidDialog.QueueType = .default
    
    private func layout(to container: UIView?) {
        container?.translates(subViews: self)
        self.top(0).bottom(0).left(0).right(0)
        
        self.translates(subViews: self.coverView, self.dialogView)
        self.coverView.top(0).bottom(0).left(0).right(0)
        self.dialogView.centerInContainer()
        self.dialogView.width(240).height(>=0)
        
        self.dialogView.positiveButton.addTarget(self, action: #selector(positiveTapped(_:)), for: .touchUpInside)
        self.dialogView.negativeButton.addTarget(self, action: #selector(negativeTapped(_:)), for: .touchUpInside)
        
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        
        self.dialogView.titleLabel.text = self.title
        self.dialogView.messageLabel.text = self.message
        self.dialogView.positiveButton.setTitle(self.positive, for: UIControlState.normal)
        self.dialogView.negativeButton.isHidden = self.negative == nil
        self.dialogView.negativeButton.setTitle(self.negative, for: UIControlState.normal)
    }
    
    @discardableResult
    public func show(to view: UIView?, animated: Bool = true, queue: AndroidDialog.QueueType = .default) -> Self {
        self.layout(to: view ?? UIApplication.shared.keyWindow)
        self.queueType = queue
        self.queueType.queue.async {
            self.queueType.semaphore?.wait()
            DispatchQueue.main.async {
                self._show(animated: animated)
            }
        }
        return self
    }
    
    private func _show(animated: Bool) {
        self.isHidden = false
        if animated {
            self.alpha = 0
            self.dialogView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1
                self.dialogView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }, completion: nil)
        } else {
            self.alpha = 1
        }
    }
    
    public func hide(animated: Bool = true) {
        self._hide(animated: animated)
    }
    
    private func _hide(animated: Bool) {
        if animated {
            self.alpha = 1
            self.dialogView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
                self.dialogView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
            }) { (f) in
                if f {
                    self.dead()
                }
            }
        } else {
            self.dead()
        }
    }
    
    private func dead() {
        self.removeFromSuperview()
        self.queueType.semaphore?.signal()
    }
    
    @objc
    private func positiveTapped(_ sender: UIButton) {
        if let pa = self.positiveAction {
            pa(self)
        } else {
            self.hide()
        }
    }
    
    @objc
    private func negativeTapped(_ sender: UIButton) {
        if let na = self.negativeAction {
            na(self)
        } else {
            self.hide()
        }
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        
    }
}

public extension AndroidDialog {
    public class ContextView: UIView {
        public private(set) var titleLabel: UILabel           = UILabel.init()
        public private(set) var messageLabel: UILabel         = UILabel.init()
        public private(set) var positiveButton: UIButton      = UIButton.init(type: .custom)
        public private(set) var negativeButton: UIButton      = UIButton.init(type: .custom)
        
        public init() {
            super.init(frame: .zero)
            self.layout()
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.layout()
        }
        
        public func styleSubviews() {
            self.backgroundColor = UIColor.white
            
            [self.titleLabel, self.messageLabel].style { (label) in
                label.numberOfLines = 0
                label.textAlignment = .left
            }
            
            self.titleLabel.textColor = UIColor.darkText
            self.messageLabel.textColor = UIColor.lightGray
            
            self.titleLabel.font = UIFont.systemFont(ofSize: 17)
            self.messageLabel.font = UIFont.systemFont(ofSize: 14)
            
            [self.positiveButton, self.negativeButton].style { (button) in
                button.setTitleColor(#colorLiteral(red: 0.05, green:0.49, blue:0.98, alpha:1.00), for: .normal)
                button.setTitleColor(UIColor.lightGray, for: .highlighted)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            }
            
            self.negativeButton.isHidden = true
        }
        
        private func layout() {
            self.translates(subViews: self.titleLabel, self.messageLabel, self.positiveButton, self.negativeButton)
            
            let marginH: CGFloat = 16
            let marginV: CGFloat = 8
            
            self.styleSubviews()
            
            self.titleLabel.left(marginH).right(marginH).top(marginH).height(>=17)
            self.messageLabel.left(marginH).right(marginH).height(>=14)
            self.messageLabel.topAttribute == self.titleLabel.bottomAttribute + marginV
            
            self.positiveButton.right(marginH).bottom(marginH).height(>=10).width(>=40)
            self.negativeButton.height(>=10).width(>=40)
            self.positiveButton.topAttribute == self.messageLabel.bottomAttribute + marginH
            self.negativeButton.rightAttribute == self.positiveButton.leftAttribute - marginH
            self.negativeButton.bottomAttribute == self.positiveButton.bottomAttribute
        }
    }
}

public typealias AlertDialog = AndroidDialog
