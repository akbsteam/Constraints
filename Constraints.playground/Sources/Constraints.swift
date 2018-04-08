import UIKit

// Also see https://github.com/kean/Yalta
// Based on https://talk.objc.io/episodes/S01E75-auto-layout-with-key-paths

public enum ConstraintId
{
    case leading
    case trailing
    case left
    case right
    case top
    case bottom
    case width
    case height
    case centerX
    case centerY
    case firstBaseline
    case lastBaseline
}

public typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

public func equalToSuperView() -> [ConstraintId: Constraint]
{
    return [
        .width: equal(\.widthAnchor),
        .centerX: equal(\.centerXAnchor),
        .height: equal(\.heightAnchor),
        .centerY: equal(\.centerYAnchor)
    ]
}

public func centeredInSuperView(offset: CGPoint = .zero) -> [ConstraintId: Constraint]
{
    return [
        .centerX: equal(\.centerXAnchor, constant: offset.x),
        .centerY: equal(\.centerYAnchor, constant: offset.y)
    ]
}

public func sizedToRect(_ rect: CGRect) -> [ConstraintId: Constraint]
{
    return [
        .width: constant(\.widthAnchor, constant: rect.size.width),
        .height: constant(\.heightAnchor, constant: rect.size.height),
        .leading: equal(\.leadingAnchor, constant: rect.origin.x),
        .top: equal(\.topAnchor, constant: rect .origin.y)
    ]
}

public func anchorEdges(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) -> [ConstraintId: Constraint]
{
    return [
        .left: equal(\.leftAnchor, to: layoutGuide.leftAnchor, constant: insets.left),
        .right: equal(\.rightAnchor, to: layoutGuide.rightAnchor, constant: insets.right),
        .top: equal(\.topAnchor, to: layoutGuide.topAnchor, constant: insets.top),
        .bottom: equal(\.bottomAnchor, to: layoutGuide.bottomAnchor, constant: insets.bottom)
    ]
}

public func anchorEdgesToSuperviewEdges(insets: UIEdgeInsets = .zero) -> [ConstraintId: Constraint]
{
    return [
        .left: equal(\.leftAnchor, constant: insets.left),
        .right: equal(\.rightAnchor, constant: insets.right),
        .top: equal(\.topAnchor, constant: insets.top),
        .bottom: equal(\.bottomAnchor, constant: insets.bottom)
    ]
}

public func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                                to toPath: KeyPath<UIView, Anchor>,
                                constant: CGFloat = 0)
    -> Constraint where Anchor: NSLayoutAnchor<Axis>
{
    return { view, parent in
        view[keyPath: keyPath].constraint(equalTo: parent[keyPath: toPath], constant: constant)
    }
}

public func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                                to other: NSLayoutAnchor<Axis>, constant: CGFloat = 0)
    -> Constraint where Anchor: NSLayoutAnchor<Axis>
{
    return { view, _ in
        view[keyPath: keyPath].constraint(equalTo: other, constant: constant)
    }
}

public func equal<Dimension>(_ keyPath: KeyPath<UIView, Dimension>,
                             to other: Dimension, constant: CGFloat = 0)
    -> Constraint where Dimension: NSLayoutDimension
{
    return { view, _ in
        view[keyPath: keyPath].constraint(equalTo: other, constant: constant)
    }
}

public func equal<Dimension>(_ keyPath: KeyPath<UIView, Dimension>, constant: CGFloat = 0)
    -> Constraint where Dimension: NSLayoutDimension
{
    return equal(keyPath, to: keyPath, constant: constant)
}

public func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, constant: CGFloat = 0)
    -> Constraint where Anchor: NSLayoutAnchor<Axis>
{
    return equal(keyPath, to: keyPath, constant: constant)
}

public func constant<Dimension>(_ keyPath: KeyPath<UIView, Dimension>, constant: CGFloat = 0)
    -> Constraint where Dimension: NSLayoutDimension
{
    return { view, _ in
        view[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

extension UIView
{
    @discardableResult
    public func addSubview(_ child: UIView,
                           constraints: [ConstraintId: Constraint])
        -> [ConstraintId: NSLayoutConstraint]
    {
        if child.superview == self {
            child.removeConstraints(child.constraints)
        } else {
            self.addSubview(child)
        }
        
        return child.constrain(constraints)
    }
    
    @discardableResult
    public func addSubview(_ child: UIView, constraints: [Constraint]) -> [NSLayoutConstraint]
    {
        if child.superview == self {
            child.removeConstraints(child.constraints)
        } else {
            self.addSubview(child)
        }
        
        return child.constrain(constraints)
    }
    
    @discardableResult
    public func constrain(_ constraints: [ConstraintId: Constraint]) -> [ConstraintId: NSLayoutConstraint]
    {
        guard let superview = self.superview else { assertionFailure("View has no superview"); return [:] }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let mappedConstraints = constraints.mapValues { $0(self, superview) }
        let values = Array(mappedConstraints.values)
        
        NSLayoutConstraint.activate(values)
        return mappedConstraints
    }
    
    @discardableResult
    public func constrain(_ constraints: [Constraint]) -> [NSLayoutConstraint]
    {
        guard let superview = self.superview else { assertionFailure("View has no superview"); return [] }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let values = constraints.map { $0(self, superview) }
        
        NSLayoutConstraint.activate(values)
        return values
    }
}
