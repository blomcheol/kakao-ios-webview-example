//
//  ViewController.swift
//  KakaoSDKWebViewExample
//
//  Created by Richard Jeon on 11/09/2019.
//  Copyright © 2019 Richard Jeon. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webViews = [WKWebView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.home(self)
    }
    
    func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: configuration)
        
        // set delegate
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.allowsBackForwardNavigationGestures = true
        
        self.view.addSubview(webView)
        self.webViews.append(webView)
        
        return webView
    }
    
    /// ---------- 팝업 열기 ----------
    /// - 카카오 JavaScript SDK의 로그인 기능은 popup을 이용합니다.
    /// - window.open() 호출 시 별도 팝업 webview가 생성되어야 합니다.
    ///
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let frame = self.webViews.last?.frame else {
            return nil
        }
        return createWebView(frame: frame, configuration: configuration)
    }
    
    /// ---------- 팝업 닫기 ----------
    /// - window.close()가 호출되면 앞에서 생성한 팝업 webview를 닫아야 합니다.
    ///
    func webViewDidClose(_ webView: WKWebView) {
        self.webViews.popLast()?.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url?.absoluteString ?? "")
        
        // 카카오링크 스킴인 경우 open을 시도합니다.
        if let url = navigationAction.request.url, url.scheme == "kakaolink" {
            print("Execute KakaoLink!")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        
        // 서비스 상황에 맞는 나머지 로직을 구현합니다.
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        if let topWebView = self.webViews.last {
            if topWebView.canGoBack {
                topWebView.goBack()
            } else if topWebView != self.webViews.first {
                self.webViews.popLast()?.removeFromSuperview()
            }
        }
    }
    
    @IBAction func forward(_ sender: Any) {
        self.webViews.last?.goForward()
    }
    
    @IBAction func reload(_ sender: Any) {
        self.webViews.last?.reload()
    }
    
    @IBAction func home(_ sender: Any) {
        self.webViews.removeAll()
        
        // Javascript SDK Demo 페이지
        let url = URL(string: "https://developers.kakao.com/docs/js/demos")
        
        createWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
            .load(URLRequest(url: url!))
    }
}

