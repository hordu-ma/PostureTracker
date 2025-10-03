//
//  PostureVisualization3D.swift
//  PostureTracker
//
//  3D姿态可视化组件 - 使用SceneKit实时显示头部姿态
//  Created on 2024-09-30
//

import SwiftUI
import SceneKit

struct PostureVisualization3D: UIViewRepresentable {
    
    // MARK: - 属性
    
    /// 俯仰角（度）
    var pitch: Double
    
    /// 偏航角（度）
    var yaw: Double
    
    /// 翻滚角（度）
    var roll: Double
    
    /// 是否显示坐标轴
    var showAxes: Bool = true
    
    /// 头部颜色
    var headColor: UIColor = .systemBlue
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // 基础设置
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X
        
        // 创建场景
        let scene = SCNScene()
        sceneView.scene = scene
        
        // 设置相机
        setupCamera(in: scene)
        
        // 设置光照
        setupLighting(in: scene)
        
        // 创建头部模型
        setupHeadModel(in: scene)
        
        // 创建坐标轴（可选）
        if showAxes {
            setupCoordinateAxes(in: scene)
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene,
              let headNode = scene.rootNode.childNode(withName: "head", recursively: true) else {
            return
        }
        
        // 更新头部旋转
        updateHeadRotation(headNode)
        
        // 更新颜色（如果需要）
        updateHeadColor(headNode)
    }
    
    // MARK: - 场景设置
    
    /// 设置相机
    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.camera?.fieldOfView = 60
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    /// 设置光照
    private func setupLighting(in scene: SCNScene) {
        // 环境光
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
        ambientLightNode.light?.intensity = 400
        scene.rootNode.addChildNode(ambientLightNode)
        
        // 主光源
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.color = UIColor.white
        lightNode.light?.intensity = 800
        lightNode.position = SCNVector3(x: 2, y: 2, z: 2)
        lightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(lightNode)
    }
    
    /// 创建头部模型
    private func setupHeadModel(in scene: SCNScene) {
        // 创建椭球体代表头部
        let headGeometry = SCNSphere(radius: 0.8)
        headGeometry.segmentCount = 32
        
        // 稍微拉长椭球体使其更像头部
        headGeometry.transform = SCNMatrix4MakeScale(0.8, 1.0, 0.9)
        
        // 设置材质
        let material = SCNMaterial()
        material.diffuse.contents = headColor
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        material.metalness.contents = 0.1
        material.roughness.contents = 0.3
        
        headGeometry.firstMaterial = material
        
        // 创建节点
        let headNode = SCNNode(geometry: headGeometry)
        headNode.name = "head"
        scene.rootNode.addChildNode(headNode)
        
        // 添加面部特征标记
        addFaceFeatures(to: headNode)
    }
    
    /// 添加面部特征标记
    private func addFaceFeatures(to headNode: SCNNode) {
        // 鼻子（小圆锥体）
        let noseGeometry = SCNCone(topRadius: 0, bottomRadius: 0.08, height: 0.2)
        let noseMaterial = SCNMaterial()
        noseMaterial.diffuse.contents = UIColor.systemRed
        noseGeometry.firstMaterial = noseMaterial
        
        let noseNode = SCNNode(geometry: noseGeometry)
        noseNode.position = SCNVector3(x: 0, y: 0.1, z: 0.7)
        noseNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi / 2)
        headNode.addChildNode(noseNode)
        
        // 眼睛（两个小球体）
        let eyeGeometry = SCNSphere(radius: 0.08)
        let eyeMaterial = SCNMaterial()
        eyeMaterial.diffuse.contents = UIColor.black
        eyeGeometry.firstMaterial = eyeMaterial
        
        // 左眼
        let leftEyeNode = SCNNode(geometry: eyeGeometry)
        leftEyeNode.position = SCNVector3(x: -0.25, y: 0.2, z: 0.6)
        headNode.addChildNode(leftEyeNode)
        
        // 右眼
        let rightEyeNode = SCNNode(geometry: eyeGeometry)
        rightEyeNode.position = SCNVector3(x: 0.25, y: 0.2, z: 0.6)
        headNode.addChildNode(rightEyeNode)
    }
    
    /// 创建坐标轴
    private func setupCoordinateAxes(in scene: SCNScene) {
        let axisLength: Float = 1.5
        let axisRadius: Float = 0.02
        
        // X轴（红色）
        let xAxisGeometry = SCNCylinder(radius: CGFloat(axisRadius), height: CGFloat(axisLength))
        let xAxisMaterial = SCNMaterial()
        xAxisMaterial.diffuse.contents = UIColor.red
        xAxisGeometry.firstMaterial = xAxisMaterial
        
        let xAxisNode = SCNNode(geometry: xAxisGeometry)
        xAxisNode.position = SCNVector3(x: axisLength / 2, y: 0, z: 0)
        xAxisNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float.pi / 2)
        scene.rootNode.addChildNode(xAxisNode)
        
        // Y轴（绿色）
        let yAxisGeometry = SCNCylinder(radius: CGFloat(axisRadius), height: CGFloat(axisLength))
        let yAxisMaterial = SCNMaterial()
        yAxisMaterial.diffuse.contents = UIColor.green
        yAxisGeometry.firstMaterial = yAxisMaterial
        
        let yAxisNode = SCNNode(geometry: yAxisGeometry)
        yAxisNode.position = SCNVector3(x: 0, y: axisLength / 2, z: 0)
        scene.rootNode.addChildNode(yAxisNode)
        
        // Z轴（蓝色）
        let zAxisGeometry = SCNCylinder(radius: CGFloat(axisRadius), height: CGFloat(axisLength))
        let zAxisMaterial = SCNMaterial()
        zAxisMaterial.diffuse.contents = UIColor.blue
        zAxisGeometry.firstMaterial = zAxisMaterial
        
        let zAxisNode = SCNNode(geometry: zAxisGeometry)
        zAxisNode.position = SCNVector3(x: 0, y: 0, z: axisLength / 2)
        zAxisNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float.pi / 2)
        scene.rootNode.addChildNode(zAxisNode)
    }
    
    // MARK: - 更新方法
    
    /// 更新头部旋转
    private func updateHeadRotation(_ headNode: SCNNode) {
        // 将角度转换为弧度
        let pitchRad = Float(pitch.degreesToRadians)
        let yawRad = Float(yaw.degreesToRadians)
        let rollRad = Float(roll.degreesToRadians)
        
        // 创建旋转矩阵
        // 注意：SceneKit的坐标系与姿态角度的对应关系
        let pitchRotation = SCNMatrix4MakeRotation(-pitchRad, 1, 0, 0) // 绕X轴旋转
        let yawRotation = SCNMatrix4MakeRotation(yawRad, 0, 1, 0)      // 绕Y轴旋转
        let rollRotation = SCNMatrix4MakeRotation(rollRad, 0, 0, 1)    // 绕Z轴旋转
        
        // 组合旋转：先偏航，再俯仰，最后翻滚
        var transform = SCNMatrix4Identity
        transform = SCNMatrix4Mult(transform, yawRotation)
        transform = SCNMatrix4Mult(transform, pitchRotation)
        transform = SCNMatrix4Mult(transform, rollRotation)
        
        // 应用平滑动画
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        headNode.transform = transform
        SCNTransaction.commit()
    }
    
    /// 更新头部颜色
    private func updateHeadColor(_ headNode: SCNNode) {
        guard let geometry = headNode.geometry,
              let material = geometry.firstMaterial else { return }
        
        material.diffuse.contents = headColor
    }
}

// MARK: - 扩展：角度转换

private extension Double {
    /// 角度转弧度
    var degreesToRadians: Double {
        return self * .pi / 180.0
    }
}

// MARK: - 预览

#Preview("3D姿态可视化 - 正常姿势") {
    PostureVisualization3D(
        pitch: 0,
        yaw: 0,
        roll: 0
    )
    .frame(height: 200)
    .background(Color(.systemGray6))
    .cornerRadius(12)
}

#Preview("3D姿态可视化 - 前倾姿势") {
    PostureVisualization3D(
        pitch: -20,
        yaw: 5,
        roll: -3
    )
    .frame(height: 200)
    .background(Color(.systemGray6))
    .cornerRadius(12)
}

#Preview("3D姿态可视化 - 侧倾姿势") {
    PostureVisualization3D(
        pitch: -10,
        yaw: 15,
        roll: -12
    )
    .frame(height: 200)
    .background(Color(.systemGray6))
    .cornerRadius(12)
}

#Preview("3D姿态可视化 - 暗色模式") {
    PostureVisualization3D(
        pitch: -15,
        yaw: 8,
        roll: -5,
        headColor: .systemPurple
    )
    .frame(height: 200)
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .preferredColorScheme(.dark)
}

#Preview("3D姿态可视化 - 无坐标轴") {
    PostureVisualization3D(
        pitch: -12,
        yaw: 10,
        roll: -8,
        showAxes: false,
        headColor: .systemGreen
    )
    .frame(height: 200)
    .background(Color(.systemGray6))
    .cornerRadius(12)
}