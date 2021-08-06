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
    
    let realm = try! Realm()
    
    //Db内のタスクが格納されるリスト
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //どのカテゴリが選ばれているかを示す
    var tapped: Int = 0
    
    // 件数を示す
    @IBOutlet weak var resultText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        resultText.text = "カテゴリ：すべて"
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
            resultText.text = "カテゴリ：すべて"
            tableView.reloadData()
    
    }
    
    //以下、検索の絞り込み
    
    @IBAction func workTapped(_ sender: Any) {
        if tapped == 1 {
        tapped = 0
        }else{
        tapped = 1
        }
        setFilter(tapped: tapped)
    }
    @IBAction func familyTapped(_ sender: Any) {
        if tapped == 2 {
        tapped = 0
        }else{
        tapped = 2
        }
        setFilter(tapped: tapped)
    }
    @IBAction func joyTapped(_ sender: Any) {
        if tapped == 3 {
        tapped = 0
        }else{
        tapped = 3
        }
        setFilter(tapped: tapped)
    }
    @IBAction func othersTapped(_ sender: Any) {
        if tapped == 4 {
        tapped = 0
        }else{
        tapped = 4
        }
        setFilter(tapped: tapped)
    }
    
    
    func setFilter(tapped a: Int){
        
        //検索フィルターをかけた時の動作
       
        switch a{
        case 1:
                resultText.text = "カテゴリ：仕事"
                taskArray = realm.objects(Task.self).filter("category == '仕事'").sorted(byKeyPath: "date", ascending: true)
                tableView.reloadData()
        case 2:
                resultText.text = "カテゴリ：家庭"
                taskArray = realm.objects(Task.self).filter("category == '家庭'").sorted(byKeyPath: "date", ascending: true)
                tableView.reloadData()
        case 3:
                resultText.text = "カテゴリ：遊び"
                taskArray = realm.objects(Task.self).filter("category == '遊び'").sorted(byKeyPath: "date", ascending: true)
                tableView.reloadData()
        case 4:
                resultText.text = "カテゴリ：その他"
                taskArray = realm.objects(Task.self).filter("category == 'その他'").sorted(byKeyPath: "date", ascending: true)
                tableView.reloadData()
        default:
                resultText.text = "カテゴリ：すべて"
                taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
                tableView.reloadData()
        }
    }
}






