//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

// syntactic sure to be able to pass an optional UIImage to Image
// (normally it would only take a non-optional UIImage)

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}

// syntactic sugar
// lots of times we want a simple button
// with just text or a label or a systemImage
// but we want the action it performs to be animated
// (i.e. withAnimation)
// this just makes it easy to create such a button
// and thus cleans up our code

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }
    }
}

// simple struct to make it easier to show configurable Alerts
// just an Identifiable struct that can create an Alert on demand
// use .alert(item: $alertToShow) { theIdentifiableAlert in ... }
// where alertToShow is a Binding<IdentifiableAlert>?
// then any time you want to show an alert
// just set alertToShow = IdentifiableAlert(id: "my alert") { Alert(title: ...) }
// of course, the string identifier has to be unique for all your different kinds of alerts


struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
    //可方便使用闭包自定义
    init(id: String, alert: @escaping () -> Alert) {
        self.id = id
        self.alert = alert
    }
    //所有参数都可使用String
    init(id: String, title: String, message: String) {
        self.id = id
        alert = { Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK"))) }
    }
    //自动生成id内容为String
    init(title: String, message: String) {
        self.id = title + message
        alert = { Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK"))) }
    }
}

// a button that does undo (preferred) or redo
// also has a context menu which will display
// the given undo or redo description for each

struct UndoButton: View {
    let undo: String?
    let redo: String?
    
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        let canUndo = undoManager?.canUndo ?? false
        let canRedo = undoManager?.canRedo ?? false
        if canUndo || canRedo {
            Button {
                if canUndo {
                    undoManager?.undo()
                } else {
                    undoManager?.redo()
                }
            } label: {
                if canUndo {
                    Image(systemName: "arrow.uturn.backward.circle")
                } else {
                    Image(systemName: "arrow.uturn.forward.circle")
                }
            }
            .contextMenu {
                if canUndo {
                    Button {
                        undoManager?.undo()
                    } label: {
                        Label(undo ?? "撤销", systemImage: "arrow.uturn.backward")
                    }
                }
                if canRedo {
                    Button {
                        undoManager?.redo()
                    } label: {
                        Label(redo ?? "重做", systemImage: "arrow.uturn.forward")
                    }
                }
            }
        }
    }
}

extension UndoManager {
    var optionalUndoMenuItemTitle: String? {
        canUndo ? undoMenuItemTitle : nil
    }
    var optionalRedoMenuItemTitle: String? {
        canRedo ? redoMenuItemTitle : nil
    }
}


extension View {
    //替换toolBar 在水平紧凑的环境中，它在工具栏中放置一个按钮要弹出上下文菜单,限制内容为@ViewBuilder而非ToolbarItems
    func compactableToolbar<Content>(@ViewBuilder content: () -> Content) -> some View where Content: View {
        self.toolbar {//创建一个工具栏并放入闭包里的内容
            content().modifier(CompactableIntoContextMenu())//应用我们创建的modifier
        }
    }
}

//监听水平尺寸状态根据条件返回带有内容的上下文菜单的单个按钮(如果水平压缩)或者不变的content
struct CompactableIntoContextMenu: ViewModifier {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass //从环境变量获取当前水平尺寸
    var compact: Bool { horizontalSizeClass == .compact }//监听是否处于宽屏模式
    #else
    let compact = false //macOS里永远为false
    #endif
    
    func body(content: Content) -> some View {
        if compact {
            //处于紧凑的尺寸类
            Button {
                //无动作，长按弹出“上下文”菜单
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .contextMenu {
                content //将原来的工具栏图标压缩到“上下文”菜单里
            }
        } else {
            content //在顶上显示所有工具栏图标
        }
    }
}
