//
//  ARSearchItemViewController.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import Foundation
import ARKit
import RealityKit
import UIKit

class ARSearchItemViewController: ARView, ARSessionDelegate {

    var arItem: ARItem

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private let distanceLabel = UILabel()
    private var trackedAnchorEntity: AnchorEntity?

    var soundPlayer: AVAudioPlayer?

    private var overlayView: UIView?
    private var overlayAnchorPosition: SIMD3<Float>?
    private var baseOverlaySize = CGSize(width: 120, height: 80)

    private let guideContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let guideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "Please go to this location to find the items you put before"
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    init(arworldMapId: ARItem) {
        self.arItem = arworldMapId
        super.init(frame: .zero)
        setupAR()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor @preconcurrency required dynamic init(
        frame frameRect: CGRect
    ) {
        fatalError("init(frame:) has not been implemented")
    }

    private func setupAR() {

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapInAR)))

        session.delegate = self

        setupInitialGuideView()
        loadARWorldMap(arView: self, arConfiguration: config)

        setupCoachingOverlay()
        configStatusLabel()
        configDistanceLabel()

    }


    private func configDistanceLabel() {

        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 40
        let bottomPadding: CGFloat = 50

        distanceLabel.frame = CGRect(
            x: (bounds.width - labelWidth) / 2,
            y: bounds.height - labelHeight - bottomPadding,
            width: labelWidth,
            height: labelHeight
        )

        distanceLabel.textColor = .white
        distanceLabel.backgroundColor = UIColor.black
        distanceLabel.textAlignment = .center
        distanceLabel.layer.cornerRadius = 8
        distanceLabel.layer.masksToBounds = true
        distanceLabel.text = "Distance: --"

        distanceLabel.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]

        addSubview(distanceLabel)

    }

    private func updateDistanceLabel() {

        guard let camera = session.currentFrame?.camera,
              let anchorEntity = trackedAnchorEntity else {
            return
        }

        let anchorPosition = anchorEntity.position(relativeTo: nil)

        let cameraTransform = camera.transform
        let cameraPosition = simd_float3(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )

        // Calculate the distance
        let distance = distance(cameraPosition, anchorPosition)

        DispatchQueue.main.async {
            if distance < 1.0 {
                self.distanceLabel.text = "You are nearby the object!"
                self.distanceLabel.textColor = .black
                self.distanceLabel.backgroundColor = UIColor.green
            } else {
                self.distanceLabel.text = String(format: "Distance: %.2f m", distance)
                self.distanceLabel.textColor = .white
                self.distanceLabel.backgroundColor = UIColor.black
            }
        }
    }

    private func setupCoachingOverlay() {

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .anyPlane
        addSubview(coachingOverlay)

    }

    private func configStatusLabel() {

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)

        statusLabel.textColor = .black
        statusLabel.backgroundColor = UIColor.white
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 12
        statusLabel.layer.masksToBounds = true
        statusLabel.text = "Move around to match the saved AR World Map..."

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -125),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

    }


    @objc func handleTapInAR() {
        print("Hello! Tap detected in AR.")
    }

    private func loadARWorldMap(arView: ARView, arConfiguration: ARWorldTrackingConfiguration) {

        print("Loading AR World Map: \(arItem)")

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let worldMapURL = documentsDirectory.appendingPathComponent(
            "\(arItem.arWorldMapId)"
        )

        do {

            let worldMapData = try Data(contentsOf: worldMapURL)
            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: worldMapData) else {
                print("Error: Couldn't unarchive ARWorldMap from data")
                arView.session.run(arConfiguration)
                return
            }

            arConfiguration.initialWorldMap = worldMap
            print("Successfully loaded AR World Map: \(arItem)")

            arView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])

        } catch {
            print("Error loading AR World Map: \(error.localizedDescription)")
            arView.session.run(arConfiguration)
        }
    }



    private func createDownArrow() -> ModelEntity? {
        let arrowMaterial = SimpleMaterial(
            color: .init(red: 0.204, green: 0.780, blue: 0.349, alpha: 1),
            isMetallic: false
        )

        // shaft
        let shaftMesh = MeshResource.generateCylinder(height: 0.16, radius: 0.01)
        let shaftEntity = ModelEntity(mesh: shaftMesh, materials: [arrowMaterial])

        // arrow head
        let headMesh = MeshResource.generateCone(height: 0.08, radius: 0.04)
        let headEntity = ModelEntity(mesh: headMesh, materials: [arrowMaterial])

        headEntity.position = SIMD3<Float>(0, -0.12, 0)
        headEntity.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))

        shaftEntity.addChild(headEntity)

        return shaftEntity
    }

    private func restorePreviousAnchor() {
        guard let anchors = session.currentFrame?.anchors else { return }

        for anchor in anchors {
            print("Anchors Name: \(String(describing: anchor.name))")
            if anchor.name == arItem.anchorName {
                self.hasRestoredAnchors = true
                print("🎯 Found matching anchor ID: \(arItem.anchorName)")

                self.playMatchSound()

                self.provideFeedback()

                let anchorEntity = AnchorEntity(world: anchor.transform)

                if let arrowEntity = createDownArrow() {
                    arrowEntity.position = SIMD3<Float>(0, 0.15, 0)
                    anchorEntity.addChild(arrowEntity)
                    self.animateFloating(entity: arrowEntity)
                }

                scene.addAnchor(anchorEntity)
                trackedAnchorEntity = anchorEntity

                let worldPosition = anchor.transform.columns.3
                let overlayPosition = SIMD3<Float>(
                    worldPosition.x - 0.15, 
                    worldPosition.y,
                    worldPosition.z
                )

                addModernOverlay(at: overlayPosition)

                return
            }
        }

        print("⚠️ No matching anchor found for ID: \(arItem.anchorName)")
    }


    var hasRestoredAnchors = false

    // MARK: - ARSessionDelegate (Detect when AR Map is matched)
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {

        DispatchQueue.main.async {
            if frame.worldMappingStatus == .mapped, !self.hasRestoredAnchors {
                self.statusLabel.text = "AR World Map Matched! 🎉"
                print("✅ AR World Map successfully matched.")

                self.restorePreviousAnchor()
            }

            if frame.camera.trackingState == .limited(.relocalizing) {
                self.statusLabel.text = "Move your device to the location shown in the image."
            }

            // Update distance every frame
            self.updateDistanceLabel()
            self.updateOverlayPosition()
        }

    }


    func animateFloating(entity: ModelEntity) {

        let baseTransform = entity.transform

        let upTransform = Transform(
            translation: baseTransform.translation + SIMD3(0, 0.05, 0)
        )

        entity.move(to: upTransform, relativeTo: entity.parent, duration: 1.0, timingFunction: .easeInOut)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            entity.move(to: baseTransform, relativeTo: entity.parent, duration: 1.0, timingFunction: .easeInOut)

            // Repeat animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.animateFloating(entity: entity)
            }
        }

    }
}

// MARK: Item Info Overlay View
extension ARSearchItemViewController {


    private func addModernOverlay(at worldPosition: SIMD3<Float>) {
        overlayAnchorPosition = worldPosition

        overlayView?.removeFromSuperview()

        let overlay = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = overlay.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.addSubview(blurView)

        overlay.layer.cornerRadius = 12
        overlay.layer.masksToBounds = true
        overlay.layer.borderWidth = 0.5
        overlay.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        // Content view
        let contentView = blurView.contentView

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = arItem.itemName
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .darkText
        titleLabel.textAlignment = .left
        titleLabel.frame = CGRect(x: 12, y: 12, width: overlay.bounds.width - 24, height: 20)
        titleLabel.sizeToFit()
        contentView.addSubview(titleLabel)

        // Description label
        let descLabel = UILabel()
        descLabel.text = arItem.itemDescription
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = .darkGray
        descLabel.textAlignment = .left
        descLabel.numberOfLines = 0
        descLabel.frame = CGRect(x: 12, y: titleLabel.frame.maxY + 8,
                                 width: overlay.bounds.width - 24, height: 0)
        descLabel.sizeToFit()
        contentView.addSubview(descLabel)

        let totalHeight = titleLabel.frame.maxY + descLabel.frame.height + 20
        let totalWidth = max(titleLabel.frame.width, descLabel.frame.width) + 24
        overlay.frame.size = CGSize(width: max(totalWidth, 200), height: totalHeight)

        baseOverlaySize = overlay.frame.size

        overlay.alpha = 0
        addSubview(overlay)
        self.overlayView = overlay

        updateOverlayPosition()
    }

    // Update overlay position and size based on 3D -> 2D projection
    private func updateOverlayPosition() {

        guard let overlayView = overlayView,
              let worldPosition = overlayAnchorPosition else { return }

        // Create an offset position that's further above and to the right of the anchor
        let offsetPosition = SIMD3<Float>(
            worldPosition.x + 0.25,
            worldPosition.y + 0.22,
            worldPosition.z
        )

        // Get camera position
        let cameraPosition = self.cameraTransform.matrix.columns.3
        let cameraPosVector = SIMD3<Float>(cameraPosition.x, cameraPosition.y, cameraPosition.z)

        let distanceToCamera = distance(offsetPosition, cameraPosVector)

        if let screenPosition = self.project(offsetPosition) {
            let scaleFactor = 1.0 / distanceToCamera
            let scaledWidth = baseOverlaySize.width * CGFloat(scaleFactor)
            let scaledHeight = baseOverlaySize.height * CGFloat(scaleFactor)

            overlayView.frame.size = CGSize(width: scaledWidth, height: scaledHeight)
            overlayView.center = CGPoint(
                x: CGFloat(screenPosition.x),
                y: CGFloat(screenPosition.y)
            )

            overlayView.layer.cornerRadius = 12 * CGFloat(scaleFactor)

            if let blurView = overlayView.subviews.first as? UIVisualEffectView,
               let titleLabel = blurView.contentView.subviews.first as? UILabel,
               let descLabel = blurView.contentView.subviews.last as? UILabel {

                let padding = 12 * CGFloat(scaleFactor)

                titleLabel.frame = CGRect(
                    x: padding,
                    y: padding,
                    width: scaledWidth - (padding * 2),
                    height: 20 * CGFloat(scaleFactor)
                )
                titleLabel.font = UIFont.systemFont(
                    ofSize: 16 * CGFloat(scaleFactor),
                    weight: .semibold
                )

                descLabel.frame = CGRect(
                    x: padding,
                    y: titleLabel.frame.maxY + (4 * CGFloat(scaleFactor)),
                    width: scaledWidth - (padding * 2),
                    height: 40 * CGFloat(scaleFactor)
                )
                descLabel.font = UIFont.systemFont(
                    ofSize: 14 * CGFloat(scaleFactor),
                    weight: .regular
                )
            }

            // Check if in front of camera
            let directionToAnchor = normalize(offsetPosition - cameraPosVector)
            let cameraForward = -SIMD3<Float>(
                self.cameraTransform.matrix.columns.2.x,
                self.cameraTransform.matrix.columns.2.y,
                self.cameraTransform.matrix.columns.2.z
            )

            if dot(directionToAnchor, cameraForward) > 0 {
                UIView.animate(withDuration: 0.2) {
                    overlayView.alpha = 1.0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    overlayView.alpha = 0.0
                }
            }
        } else {
            overlayView.alpha = 0.0
        }
    }

    func provideFeedback() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(.success)
    }
}

// MARK: Image Guide View
extension ARSearchItemViewController {

    private func setupInitialGuideView() {

        guideContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(guideContainerView)

        guideImageView.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false

        guideContainerView.addSubview(guideImageView)
        guideContainerView.addSubview(guideLabel)

        // constraint properties that can be modified later
        let centerXConstraint = guideContainerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        let centerYConstraint = guideContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        let widthConstraint = guideContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9)
        let heightConstraint = guideContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)

        // initial constraints for full-screen mode
        NSLayoutConstraint.activate([
            centerXConstraint,
            centerYConstraint,
            widthConstraint,
            heightConstraint,

            guideImageView.topAnchor.constraint(equalTo: guideContainerView.topAnchor, constant: 20),
            guideImageView.leadingAnchor.constraint(equalTo: guideContainerView.leadingAnchor, constant: 20),
            guideImageView.trailingAnchor.constraint(equalTo: guideContainerView.trailingAnchor, constant: -20),
            guideImageView.heightAnchor.constraint(equalTo: guideContainerView.heightAnchor, multiplier: 0.7),

            guideLabel.topAnchor.constraint(equalTo: guideImageView.bottomAnchor, constant: 20),
            guideLabel.leadingAnchor.constraint(equalTo: guideContainerView.leadingAnchor, constant: 20),
            guideLabel.trailingAnchor.constraint(equalTo: guideContainerView.trailingAnchor, constant: -20),
            guideLabel.bottomAnchor.constraint(lessThanOrEqualTo: guideContainerView.bottomAnchor, constant: -20)
        ])

        // Set the captured image
        if let image = UIImage(data: arItem.capturedImage) {
            guideImageView.image = image
        }
        let delay = 3.0
        // Animate to corner after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

            self.animateGuideViewToCorner(
                centerXConstraint: centerXConstraint,
                centerYConstraint: centerYConstraint,
                widthConstraint: widthConstraint,
                heightConstraint: heightConstraint
            )

        }
    }

    private func animateGuideViewToCorner(
        centerXConstraint: NSLayoutConstraint,
        centerYConstraint: NSLayoutConstraint,
        widthConstraint: NSLayoutConstraint,
        heightConstraint: NSLayoutConstraint
    ) {
        // Deactivate center constraints
        NSLayoutConstraint.deactivate([
            centerXConstraint,
            centerYConstraint,
            widthConstraint,
            heightConstraint
        ])

        // Create and activate corner constraints
        let topConstraint = guideContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20)
        let leadingConstraint = guideContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        let newWidthConstraint = guideContainerView.widthAnchor.constraint(equalToConstant: 120)
        let newHeightConstraint = guideContainerView.heightAnchor.constraint(equalToConstant: 160)

        NSLayoutConstraint.activate([
            topConstraint,
            leadingConstraint,
            newWidthConstraint,
            newHeightConstraint
        ])

        // Animate the change
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.guideLabel.alpha = 0
            self.layoutIfNeeded()
        } completion: { _ in
            // Adjust image view constraints if needed
            self.guideImageView.removeFromSuperview()
            self.guideImageView.translatesAutoresizingMaskIntoConstraints = false
            self.guideContainerView.addSubview(self.guideImageView)

            NSLayoutConstraint.activate([
                self.guideImageView.topAnchor.constraint(equalTo: self.guideContainerView.topAnchor, constant: 8),
                self.guideImageView.leadingAnchor.constraint(equalTo: self.guideContainerView.leadingAnchor, constant: 8),
                self.guideImageView.trailingAnchor.constraint(equalTo: self.guideContainerView.trailingAnchor, constant: -8),
                self.guideImageView.bottomAnchor.constraint(equalTo: self.guideContainerView.bottomAnchor, constant: -8)
            ])
        }
    } }



