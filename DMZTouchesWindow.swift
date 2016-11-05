//
//  DMZTouchesWindow.swift
//  DMZTouchesWindowSample
//
//  Created by dmoroz0v on 05/11/16.
//  Copyright © 2016 DMZ. All rights reserved.
//

import UIKit

// MARK: DMZTouchesWindow

open class DMZTouchesWindow : UIWindow
{
	// Color of touch circles. Default is black with 50% opacity
	public var dmz_touchesColor: UIColor = UIColor(white: 0, alpha: 0.5)

	// Radius of touch circles. Default is 20.0
	public var dmz_touchesRadius: CGFloat = 20.0

	// Determines visible touch circles. true - touch circles are visible.
	// false - touch circles are not visible. Defailt is false
	public var dmz_touchesEnabled: Bool = false {
		didSet {
			if dmz_touchesEnabled && dmz_views == nil
			{
				dmz_views = Set<DMZTouchEntity>()
			}
			else if !dmz_touchesEnabled && dmz_views != nil
			{
				dmz_views.forEach({ $0.view.removeFromSuperview() })
				dmz_views = nil
			}
		}
	}

	// Color of touch force circles. Default is nil.
	// If is nil, then will light color of dmz_touchesColor
	public var dmz_touchesForceColor: UIColor?

	// Determines visible touch force circles. true - touch force circles are no visible.
	// false - touch force circles are visible. Defailt is false
	public var dmz_touchesForceDisabled: Bool = false

	private var dmz_views: Set<DMZTouchEntity>!

	open override func sendEvent(_ event: UIEvent)
	{
		if dmz_views != nil, let allTOuches = event.allTouches
		{
			var beganTouches = Set<UITouch>()
			var endedTouches = Set<UITouch>()

			for touch in allTOuches
			{
				switch (touch.phase) {
				case .began:
					beganTouches.insert(touch)
				case .ended, .cancelled:
					endedTouches.insert(touch)
				case .moved, .stationary:
					// do nothing
					break
				}
			}

			dmz_touchesBegan(touches: beganTouches)
			dmz_touchesMoved(touches: allTOuches)
			dmz_touchesEnded(touches: endedTouches)
		}

		super.sendEvent(event)
	}

	private func dmz_touchEntity(forTouch touch: UITouch) -> DMZTouchEntity?
	{
		for touchEntity in dmz_views
		{
			if touchEntity.touch == touch
			{
				return touchEntity
			}
		}

		return nil
	}

	private func dmz_touchesBegan(touches: Set<UITouch>)
	{
		for touch in touches
		{
			var forceColor = dmz_touchesForceColor

			if forceColor == nil
			{
				let alpha = dmz_touchesColor.dmz_alpha
				forceColor = dmz_touchesColor.withAlphaComponent(alpha/2)
			}

			let view = DMZTouchView(radius: dmz_touchesRadius)
			view.setCoreColor(dmz_touchesColor)
			view.setForceColor(forceColor!)
			view.layer.zPosition = CGFloat(FLT_MAX);

			let touchEntity = DMZTouchEntity(touch: touch, view: view)

			dmz_views.insert(touchEntity)

			addSubview(view);
		}
	}

	private func dmz_touchesMoved(touches: Set<UITouch>)
	{
		for touch in touches
		{
			var forceRadius: CGFloat = 0;
			if !dmz_touchesForceDisabled && dmz_forceTouchAvailable
			{
				forceRadius = (touch.force - 0.5) / (touch.maximumPossibleForce - 0.5)
				//forceRadius = MAX(0, forceRadius);
			}

			let touchEntity = dmz_touchEntity(forTouch:touch)!
			touchEntity.view.center = touchEntity.touch.location(in: self)
			touchEntity.view.setForceRadius(forceRadius)
		}
	}

	func dmz_touchesEnded(touches: Set<UITouch>)
	{
		for touch in touches
		{
			let touchEntity = dmz_touchEntity(forTouch:touch)!
			touchEntity.view.removeFromSuperview()
			dmz_views.remove(touchEntity)
		}
	}
}

// MARK: UIColor alpha extension

fileprivate extension UIColor
{
	fileprivate var dmz_alpha: CGFloat
	{
		return CIColor(color: self).alpha
	}
}

// MARK: UIWindow force touch extension

fileprivate extension UIWindow
{
	fileprivate var dmz_forceTouchAvailable: Bool
	{
		if #available(iOS 9.0, *)
		{
			return traitCollection.forceTouchCapability == .available
		}

		return false
	}
}

// MARK: DMZTouchView

fileprivate class DMZTouchView : UIView
{
	private let core: UIView
	private let force: UIView

	public init(radius: CGFloat)
	{
		let frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)

		force = UIView(frame: frame)
		force.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		force.layer.masksToBounds = true
		force.layer.cornerRadius = radius

		core = UIView(frame: frame)
		core.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		core.layer.masksToBounds = true
		core.layer.cornerRadius = radius

		super.init(frame: frame)

		addSubview(force)
		addSubview(core)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setCoreColor(_ coreColor: UIColor)
	{
		core.backgroundColor = coreColor
	}

	public func setForceColor(_ forceColor: UIColor)
	{
		force.backgroundColor = forceColor
	}

	public func setForceRadius(_ forceRadius: CGFloat)
	{
		let scale = 1.0 + 0.6 * forceRadius
		force.transform = CGAffineTransform(scaleX: scale, y: scale)
	}
}

// MARK: DMZTouchEntity

fileprivate struct DMZTouchEntity: Hashable
{
	let touch: UITouch
	let view: DMZTouchView

	fileprivate var hashValue: Int
	{
		return touch.hashValue
	}

	public static func ==(lhs: DMZTouchEntity, rhs: DMZTouchEntity) -> Bool
	{
		return lhs.touch == rhs.touch
	}
}
