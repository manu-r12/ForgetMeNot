//
//  ARSaveItemViewConrtoller.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import UIKit
import RealityKit
import ARKit
import SwiftUI
import simd

class ARSaveItemViewController: ARView, ARSessionDelegate {

    private var anchorEntity: AnchorEntity?
    private var saveButton: UIButton?
    private var trackingLabel: UILabel?
    private var modelEntity: Entity?
    private var currentItemPos: SIMD3<Float>?
    private var backButton: UIButton?


    @MainActor private var isTrackingStable = false {
        didSet {
            updateTrackingStatus()
        }
    }

    private var viewModel = SaveItemViewModel(persistenceManager: PersistenceManager())

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setupAR()
        configBackButton()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupAR() {

        let config = ARWorldTrackingConfiguration()

        config.planeDetection = [.horizontal, .vertical]

        session.run(config)
        session.delegate = self
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapInAR)))


        let coachingOverlay = ARCoachingOverlayView()

        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        addSubview(coachingOverlay)

        addTrackingStatusLabel()


    }

    private func checkARWorldMapStatus() {

        DispatchQueue.main.async {
            if self.isTrackingStable, let currentFrame = self.session.currentFrame {
                if currentFrame.anchors.isEmpty {

                    self.trackingLabel?.text = "Move around to map the area"
                    self.trackingLabel?.backgroundColor = UIColor.orange
                    self.saveButton?.isEnabled = false
                } else {
                    self.trackingLabel?.text = "AR World Mapped! ✅ Ready to Save."
                    self.trackingLabel?.backgroundColor = UIColor.green
                    self.saveButton?.isEnabled = true
                }
            } else {
                self.trackingLabel?.text = "Tracking Unstable ❌"
                self.trackingLabel?.backgroundColor = UIColor.red
                self.saveButton?.isEnabled = false
            }
        }

    }


    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {

        DispatchQueue.main.async {
            switch frame.camera.trackingState {
            case .normal:
                self.isTrackingStable = true
            default:
                self.isTrackingStable = false
            }

            self.checkARWorldMapStatus()
        }

    }



    nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

        DispatchQueue.main.async {
            switch camera.trackingState {
            case .normal:
                self.isTrackingStable = true
            default:
                self.isTrackingStable = false
            }
        }
    }



    private func addTrackingStatusLabel() {

        let label = UILabel()
        label.text = "Initializing Tracking..."
        label.textColor = .white
        label.backgroundColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: bottomAnchor, constant: -170),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])

        trackingLabel = label

    }

    private func addSaveButton() {

        saveButton?.removeFromSuperview()

        let button = UIButton(type: .system)
        button.setTitle("Save This Item", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(showSaveItemView), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])

        saveButton = button
    }

    private func updateTrackingStatus() {

        DispatchQueue.main.async {
            if self.isTrackingStable {
                self.trackingLabel?.text = "Tracking Stable ✅"
                self.trackingLabel?.backgroundColor = .blue
                self.saveButton?.isEnabled = true
            } else {
                self.trackingLabel?.text = "Tracking Unstable ❌"
                self.trackingLabel?.backgroundColor = UIColor.red
                self.saveButton?.isEnabled = false
            }
        }

    }


    @objc private func showSaveItemView() {

        guard let itemPos = currentItemPos, let anchorName = anchorEntity?.name else {
            print("You have not placed an item?")
            return
        }
        let worldMapId = saveWorldMap()
        let currentImage = captureCurrentFrame()

        session.pause()

        // Create the SwiftUI view
        let saveView = SaveItemOverlayView(
            vm: viewModel,
            capturedImage: currentImage!,
            onDismiss: { [self] in
                print(viewModel.itemName, viewModel.itemDescription)
                print("Saving..")

                if !viewModel.itemName.isEmpty {
                    let _ = self.viewModel
                        .saveItem(
                            with: worldMapId,
                            refCapturedImage: currentImage!,
                            itemPos: itemPos, name: anchorName
                        )
                }

                if let topController = self.findTopMostViewController() {
                    topController.dismiss(animated: true) {
                        let config = ARWorldTrackingConfiguration()
                        config.planeDetection = [.horizontal, .vertical]
                        self.session.run(config)
                    }
                }
            }
        )

        let hostingController = UIHostingController(rootView: saveView)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // get the top-most view controller
        if let topController = findTopMostViewController() {
            topController.present(hostingController, animated: true)
        }
        
    }


    private func showRoomScanningGuidance() {

        guard !UserDefaults.standard.bool(forKey: "hasShownRoomScanningGuidance") else {
            return
        }

        let guidanceViewController = UIHostingController(
            rootView: RoomScanningGuidanceView(
                isPresented: .constant(true)
            )
        )

        guidanceViewController.modalPresentationStyle = .overCurrentContext
        guidanceViewController.view.backgroundColor = .clear

        guidanceViewController.view.isUserInteractionEnabled = true

        if let topController = findTopMostViewController() {
            topController.present(guidanceViewController, animated: true)
        }
    }


    @objc private func handleTapInAR(gesture: UITapGestureRecognizer) {

        guard let hitResult = raycast(
            from: gesture.location(in: self),
            allowing: .estimatedPlane,
            alignment: .any
        ).first else {
            print("Cannot observe the tap")
            return
        }

        let position = hitResult.worldTransform.columns.3

        let worldPosition = SIMD3<Float>(position.x, position.y, position.z)

        print("Tapped Position:", worldPosition)
        print("Transform Matrix:", hitResult.worldTransform)

        currentItemPos = worldPosition

        updateAnchor(at: worldPosition)
        addSaveButton()

        showRoomScanningGuidance()
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

    private func updateAnchor(at position: SIMD3<Float>) {

        anchorEntity?.removeFromParent()

        let anchorName = "Anchor-\(UUID().uuidString)"

        let anchor = ARAnchor(name: anchorName, transform: float4x4(translation: position))
        session.add(anchor: anchor)

        let anchorEntity = AnchorEntity(world: anchor.transform)
        anchorEntity.name = anchorName

        self.anchorEntity = anchorEntity

        guard let arrowEntity = createDownArrow() else { return }

        arrowEntity.position = SIMD3<Float>(0, 0.15, 0)
        anchorEntity.addChild(arrowEntity)

        scene.addAnchor(anchorEntity)

        animateFloating(entity: arrowEntity)
        print("✅ Placed ARKit anchor with name '\(anchorName)' at \(position)")
    }

    // Create a simple arrow shape using a cylinder and cone
    private func createDownArrow() -> ModelEntity? {

            let arrowMaterial = SimpleMaterial(color: .red, isMetallic: false)

            // arrow shaft
            let shaftMesh = MeshResource.generateCylinder(height: 0.08, radius: 0.005)
            let shaftEntity = ModelEntity(mesh: shaftMesh, materials: [arrowMaterial])

            // arrow head
            let headMesh = MeshResource.generateCone(height: 0.04, radius: 0.02)
            let headEntity = ModelEntity(mesh: headMesh, materials: [arrowMaterial])

            headEntity.position = SIMD3<Float>(0, -0.06, 0)
            headEntity.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))

            shaftEntity.addChild(headEntity)

            return shaftEntity
    }


    // MARK: Capture Current Frame
    private func captureCurrentFrame() -> UIImage? {
        guard let frame = session.currentFrame else { return nil }

        let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)

        let context = CIContext()

        let width = CVPixelBufferGetWidth(frame.capturedImage)
        let height = CVPixelBufferGetHeight(frame.capturedImage)

        // Create CGImage
        guard let cgImage = context.createCGImage(
            ciImage,
            from: CGRect(x: 0, y: 0, width: width, height: height)
        ) else {
            return nil
        }

        let image = UIImage(
            cgImage: cgImage,
            scale: 1.0,
            orientation: .right
        )

        return image
    }

    // MARK: Save Current AR Expereince and
    func saveWorldMap() -> String {

        let uniqueID = UUID().uuidString
        let filename = "\(uniqueID).arexperience"

        session.getCurrentWorldMap { worldMap, error in
            guard let worldMap = worldMap else { return }

            do {
                let data = try NSKeyedArchiver.archivedData(
                    withRootObject: worldMap,
                    requiringSecureCoding: true
                )

                let documentsDirectory = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]
                let savePath = documentsDirectory.appendingPathComponent(filename)

                try data.write(to: savePath, options: .atomicWrite)

                print("AR World Map is saved at the path: \(savePath)")
            } catch {
                print("Error saving world map: \(error)")
            }
        }

        return filename
    }


    private func findTopMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        var topController = window.rootViewController

        while let presented = topController?.presentedViewController {
            topController = presented
        }

        return topController
    }


}

extension ARSaveItemViewController {

    private func configBackButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle(" Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 16)

        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])

        backButton = button
    }

    @objc private func handleBackButton() {
        // Show confirmation alert if there are unsaved changes
        if let currentItemPos = currentItemPos {
            let alert = UIAlertController(
                title: "Unsaved Changes",
                message: "Are you sure you want to go back? Any unsaved item position will be lost.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Go Back", style: .destructive) { [weak self] _ in
                self?.dismissViewController()
            })

            if let topController = findTopMostViewController() {
                topController.present(alert, animated: true)
            }
        } else {
            dismissViewController()
        }
    }

    private func dismissViewController() {
        session.pause()

        // Remove any placed anchors
        anchorEntity?.removeFromParent()

        if let topController = findTopMostViewController() {
            topController.dismiss(animated: true)
        }
    }
}


extension simd_float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        self.columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
    }
}
