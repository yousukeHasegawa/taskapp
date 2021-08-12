//
//  ViewController.swift
//  taskapp
//
//  Created by Yousuke Hasegawa on 2021/08/03.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryTextView: UITextField!
    
    let realm = try! Realm()
    
    //Db内のタスクが格納されるリスト
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //どのカテゴリが選ばれているかを示す
    var tapped: Int = 0
    
    var categoryText: String!
    
    // 件数を示す
    @IBOutlet weak var resultText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        resultText.text = "カテゴリ：すべて　件数：\(taskArray.count)件"
    }

    // データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //　各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm"
        
        let dateString:String = "日時:\(formatter.string(from: task.date)) カテゴリ：\(task.category)"
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルが選択された時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for requests in requests{
                    print("/------------")
                    print(requests)
                    print("------------/")
                }
            }
        }
    }
    
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
        inputViewController.task = task
        }
    }
    //入力画面から戻ってきたときに、TableViewを更新させる
    
    override func viewWillAppear(_ animated: Bool){
            super.viewWillAppear(animated)

            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            resultText.text = "カテゴリ：すべて　件数：\(taskArray.count)件"
            tableView.reloadData()
    
    }
    
    //以下、検索の絞り込み
    
    @IBAction func categoryViewChanged(_ sender: Any) {

        if categoryTextView.text != ""{
            taskArray = realm.objects(Task.self).filter("category == '\(categoryTextView.text ?? "")'").sorted(byKeyPath: "date", ascending: true)
            resultText.text = "カテゴリ：\(categoryTextView.text ?? "すべて")　件数：\(taskArray.count)件"
        }else{
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            resultText.text = "カテゴリ：すべて　件数：\(taskArray.count)件"
        }

        tableView.reloadData()
    }


}






