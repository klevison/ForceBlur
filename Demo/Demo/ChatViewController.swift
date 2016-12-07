 //
//  ChatViewController.swift
//  ChatDemo
//
//  Created by Serhii Butenko on 8/8/16.
//  Copyright © 2016 Serhii Butenko. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ForceBlur

class ChatViewController: JSQMessagesViewController, SettingsSliderChangeable {
    
    var messages = DemoConversation
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var radius: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = WomanName
        senderId = ManID
        senderDisplayName = ManName
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: .jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: .lightGray)

        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "settings", style: .plain, target: self, action: #selector(settingsButtonTapped))
    }
    
    func settingsButtonTapped() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewControllerStoryBoardID") as! SettingsViewController
        vc.radius = radius
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func valueChanged(value: CGFloat) {
        radius = value
        self.collectionView.reloadData()
    }

    // MARK: JSQMessagesViewController method overrides
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messages.append(message!)
        
        finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let media = ExampleForceBlurPhotoMediaItem(image: UIImage(named: "preview"))
        media?.radius = radius
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: media)
        messages.append(message!)
        
        finishSendingMessage(animated: true)
    }
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        var message = messages[(indexPath as NSIndexPath).item]
        if let _ = message.media as? ForceBlurPhotoMediaItem {
            let photoItem: ForceBlurPhotoMediaItem = {
                let photoItem = ExampleForceBlurPhotoMediaItem(image: UIImage(named: "preview"))!
                photoItem.appliesMediaViewMaskAsOutgoing = false
                photoItem.radius = radius
                
                return photoItem
            }()
            
            message = JSQMessage(senderId: WomanID, displayName: WomanName, media: photoItem)!
        }
        
        return message
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[(indexPath as NSIndexPath).item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        let message = messages[(indexPath as NSIndexPath).item]
        if let image = (message.media as? JSQPhotoMediaItem)?.image {
            showImage(image)
        }
    }
    
    fileprivate func showImage(_ image: UIImage) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "image") as! ImageViewController
        let nc = UINavigationController(rootViewController: vc)
        vc.image = image
        navigationController?.present(nc, animated: true, completion: nil)
    }
}
 
