
//
//  ContentView.swift
//  testGame
//
//  Created by wearrier on 2026/04/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View
{
    var scene :SKScene
    {
        let scene = gameScene()
        scene.size = CGSize(width: NSScreen.main?.frame.width ?? 1000, height: NSScreen.main?.frame.height ?? 1000)
        scene.scaleMode = .fill
        return scene
    }
    var body: some View
    {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
}
