//
//  UIControl+Combine.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//
import Combine
import UIKit

// MARK: - Publisher

public extension UIControl {
    /// A publisher emitting events from this control.
    func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        Publishers.ControlEvent(control: self, events: events)
                  .eraseToAnyPublisher()
    }
}

public extension Combine.Publishers {
    /// A Control Event is a publisher that emits whenever the provided
    /// Control Events fire.
    struct ControlEvent<Control: UIControl>: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: Control
        private let controlEvents: Control.Event

        /// Initialize a publisher that emits a Void
        /// whenever any of the provided Control Events trigger.
        ///
        /// - parameter control: UI Control.
        /// - parameter events: Control Events.
        public init(control: Control,
                    events: Control.Event) {
            self.control = control
            self.controlEvents = events
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            event: controlEvents)

            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription

extension Combine.Publishers.ControlEvent {
    private final class Subscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: Control?

        init(subscriber: S, control: Control, event: Control.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(processControlEvent), for: event)
        }

        func request(_ demand: Subscribers.Demand) {
            // We don't care about the demand at this point.
            // As far as we're concerned - UIControl events are endless until the control is deallocated.
        }

        func cancel() {
            subscriber = nil
        }

        @objc private func processControlEvent() {
            _ = subscriber?.receive()
        }
    }
}

extension UIView {

    func publisher<G>(for gestureRecognizer: G) -> UIGestureRecognizer.Publisher<G> where G: UIGestureRecognizer {
        UIGestureRecognizer.Publisher(gestureRecognizer: gestureRecognizer, view: self)
    }
}

extension UIGestureRecognizer {

    struct Publisher<G>: Combine.Publisher where G: UIGestureRecognizer {

        typealias Output = G
        typealias Failure = Never

        let gestureRecognizer: G
        let view: UIView

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            subscriber.receive(
                subscription: Subscription(subscriber: subscriber, gestureRecognizer: gestureRecognizer, on: view)
            )
        }
    }

    class Subscription<G: UIGestureRecognizer, S: Subscriber>: Combine.Subscription where S.Input == G, S.Failure == Never {

        var subscriber: S?
        let gestureRecognizer: G
        let view: UIView

        init(subscriber: S, gestureRecognizer: G, on view: UIView) {
            self.subscriber = subscriber
            self.gestureRecognizer = gestureRecognizer
            self.view = view
            view.isUserInteractionEnabled = true
            gestureRecognizer.addTarget(self, action: #selector(handle))
            view.addGestureRecognizer(gestureRecognizer)
        }

        @objc private func handle(_ gesture: UIGestureRecognizer) {
            _ = subscriber?.receive(gestureRecognizer)
        }

        func cancel() {
            view.removeGestureRecognizer(gestureRecognizer)
        }

        func request(_ demand: Subscribers.Demand) { }
    }
}
