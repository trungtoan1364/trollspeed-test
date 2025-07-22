import SwiftUI

struct HomePageView: View {
    @State private var isNowEnabled: Bool = false
    @State private var buttonDisabled: Bool = false
    @State private var showAlert: Bool = false
    @State private var showLoading: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAnnouncement: Bool = true // 控制公告显示

    let encodedURL = "aHR0cHM6Ly9pb3Muc2w4bmI2Ni50b3Avc2p6LnBocA==" // Base64编码的 URL

    var body: some View {
        ZStack {
            // 公告视图
            if showAnnouncement {
                VStack {
                    Spacer()
                    Text("欢迎使用 Sl8\n探索新体验，尽情享受吧！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Text("点击任意位置继续")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onTapGesture {
                    showAnnouncement = false // 点击公告后关闭
                }
            } else {
                // 主视图内容
                NavigationView {
                    VStack {
                        Spacer()
                        Image("dajidaji")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                            .padding(.bottom, 20)

                        Text("三角洲·Sl8")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding(.bottom, 30)

                        Text(isNowEnabled ? "请注意演戏！" : "点击下方开启")
                            .font(.headline)
                            .foregroundColor(isNowEnabled ? .green : .gray)
                            .padding(.bottom, 15)

                        Button(action: {
                            withAnimation {
                                startLoadingThenToggleHUD()
                            }
                        }) {
                            Text(isNowEnabled ? "关闭绘制" : "打开绘制")
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(isNowEnabled ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        .disabled(buttonDisabled || showLoading)

                        Spacer()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .onAppear {
                        isNowEnabled = IsHUDEnabledBridger()
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("提示"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("关闭"))
                        )
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())

                if showLoading {
                    ProgressView("加载中...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .zIndex(1)
                }
            }
        }
    }

    func startLoadingThenToggleHUD() {
        showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLoading = false
            let action = isNowEnabled ? "disable" : "enable"
            toggleHUDOnServer(action)
        }
    }

    func xorEncryptDecrypt(_ input: String, key: String) -> String {
        let keyBytes = Array(key.utf8)
        let inputBytes = Array(input.utf8)
        var encryptedBytes: [UInt8] = []
        
        for i in 0..<inputBytes.count {
            encryptedBytes.append(inputBytes[i] ^ keyBytes[i % keyBytes.count])
        }
        
        return String(bytes: encryptedBytes, encoding: .utf8) ?? ""
    }

    func toggleHUDOnServer(_ action: String) {
        let decodedURL = decodeBase64(encodedURL)
        guard let url = URL(string: decodedURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let encryptedAction = xorEncryptDecrypt("action=\(action)", key: "E1FE2EDB464B3B40495F4ABB56FF8C73")
        request.httpBody = encryptedAction.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    alertMessage = "网络错误，请稍后再试。"
                    showAlert = true
                }
                return
            }

            guard let data = data else { return }

            do {
                if let encryptedResponse = String(data: data, encoding: .utf8) {
                    let decryptedResponse = xorEncryptDecrypt(encryptedResponse, key: "E1FE2EDB464B3B40495F4ABB56FF8C73")
                    
                    if let json = try JSONSerialization.jsonObject(with: decryptedResponse.data(using: .utf8)!, options: []) as? [String: Any],
                       let status = json["status"] as? String {
                        DispatchQueue.main.async {
                            alertMessage = status
                            showAlert = true
                            toggleHUD(action == "enable")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "服务器响应错误。"
                    showAlert = true
                }
            }
        }
        task.resume()
    }

    func decodeBase64(_ encoded: String) -> String {
        guard let data = Data(base64Encoded: encoded),
              let decodedString = String(data: data, encoding: .utf8) else {
            return ""
        }
        return decodedString
    }

    func toggleHUD(_ isActive: Bool) {
        Haptic.shared.play(.medium)
        if isNowEnabled == isActive { return }
        SetHUDEnabledBridger(isActive)

        buttonDisabled = true
        waitForNotificationBridger({
            isNowEnabled = isActive
            buttonDisabled = false
        }, !isNowEnabled)
    }
}
