//
//  ViewController.swift
//  Project 4
//
//  Created by Jeffrey Poulter on 4/18/23.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate {
    //create a new subclass of UIViewController called ViewController and tell the compiler we're safe to use as a WKNavigationDelegte
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["hackingwithswift.com", "ibm.com", "apple.com"]

        //--------------------------------------------------------
    override func loadView() {
        webView = WKWebView()  //new instance of web component assign to webView
        
        webView.navigationDelegate = self
            //delegation property to self, so when any web page navigation happens, tell me, the current view controller
        
        view = webView //make our view the root view for the view controller
    }
        //---------------------------------------------------------
    override func viewDidLoad() {
            super.viewDidLoad()
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            //adding ourself as an observer with KVO to watch estimatedProgress property, #keypath similar to #selector, context is value returned
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
            // button to navigation bar, custom title, calling openTapped when clicked
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
            //1. creates progressView instance with default view (or .bar)
            //2. Set the layout size of the bar so it fits fully
            //3. create ButtonBarItem
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            //create a new bar button with a flexible space, moves to right
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
            // calls system reload instead of our own method
        
            // Challenge #2 ----------------------------------------
        let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
            // calls system reload instead of our own method
        
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
            // calls custom forward using webView.goForward
        
        toolbarItems = [progressButton, spacer, back, forward, spacer, refresh]
            //-----------------------------------------------------
        navigationController?.isToolbarHidden = false
            //creates array of items on toolbar and show toolbar
        
        let url = URL(string: "https://" + websites[0])!
            //create a new data type (url) storing the location of the files
        
        webView.load(URLRequest(url: url))
            // creates a new URLRequest object from that URL and gives it to our web view to load
        
        webView.allowsBackForwardNavigationGestures = true
            //enables a property to swipe left or right
    }
    
        //---------------------------------------------------------
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page…", message: nil, preferredStyle: .actionSheet)
            //nil for message becasue this alert doesn't need one
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            // dedicated cancel button with style .cancel. No handler which means iOS will just dismiss the alert controller if its tapped
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
            // needed for ipad
    }
        //---------------------------------------------------------
    func openPage(action: UIAlertAction! = nil) {
        var alertTitle: String
        
        // takes one parameter, which is the UIAlertAction object that was selected by the user. won't be called if Cancel was tapped, because that had a nil handler
        
        let url = URL(string: "https://" + action.title!)!
        
        //---------------------------------------------------------
        // Challenge #1 - artificially blocked ibm to show UIAlertButton
        
        if action.title! == "ibm.com" {
            let ac = UIAlertController(title: action.title, message: "Website Blocked", preferredStyle: .alert)
            alertTitle = "Request Again"
        
            ac.addAction(UIAlertAction(title: alertTitle, style: .default, handler: nil))
            present(ac, animated: true)
            return
        }
        // End Challenge 1
        
        webView.load(URLRequest(url: url))
    }
        //---------------------------------------------------------
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        //All this method does is update our view controller's title property to be the title of the web view, which will automatically be set to the page title of the web page that was most recently loaded.
    }
        //---------------------------------------------------------
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
                progressView.progress = Float(webView.estimatedProgress)
            }
        }
        // Once you have registered a as an observer for KVO you must implement this method and tells you when an observed item has changed. For this project only keyPath is relevant
        //---------------------------------------------------------
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping(WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url

            if let host = url?.host {
                for website in websites {
                    if host.contains(website) {
                        decisionHandler(.allow)
                        return
                    }
                }
            }

            decisionHandler(.cancel)
        }
        // 1. set url to URL of navigation for clarity
        // 2. If there is a host for this URL, pull it out "website domain" - careful on unwrap
        // 3. Loop through websites putting name in website
        // 4. If the host domain is in the website (contains), allow to show
    }
