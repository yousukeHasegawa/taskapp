//
//  InputViewController.swift
//  taskapp
//
//  Created by Yousuke Hasegawa on 2021/08/03.
//

import UIKit
import RealmSwift


class InputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    


    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    let realm = try! Realm()
    var task: Task!
    
    //カテゴリのリストを挿入
    let categoryList = ["仕事", "家庭", "遊び", "その他"]

    //PickerViewで表示されているもの
    var categoryText: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        //背景をタップしたらdismisssKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryText = categoryList[1]
    }
    //PickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Pickerviewの行の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    //PickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,forComponent component: Int) ->String? {
        return categoryList[row]
    }
    
    //UIPickerViewのRowが選択されたとき
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        categoryText = categoryList[row]
    }
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = categoryText
            self.realm.add(self.task, update: .modified)
        }
     
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }

    //タスクのローカル通知を登録する
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default
        
    
        //ローカル通知が発動するtrigger(日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
        //identifier, contents, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
    
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request){ (error) in
            print(error ?? "ローカル通知登録 OK")  //errorがnilならローカル通知の登録に成功したと表示。errorが存在すればerrorを表示
        }
    
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/------------------")
                print(request)
                print("------------------/")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    */

}
