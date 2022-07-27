//
//  ViewController.swift
//  TravElite
//
//  Created by Manjot Dola on 2022-07-22.
//

import UIKit

class CellClass: UITableViewCell {
    
}

class TripDetails {
    var destination: String?
    
    init(destination: String?) {
        self.destination = destination
    }
    
}

class ViewController: UIViewController {

            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
    }

    
}

class PrefsViewController: UIViewController {

    
    @IBOutlet weak var btnPrimCuisine: UIButton!
    @IBOutlet weak var PrefsView: UIView!
    
    let transparentView = UIView()
    let PrimCuisineDropdown = UITableView()
    
    var selectedPrimCuisine = UIButton()
    
    var dataSource = [String]()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        PrimCuisineDropdown.delegate = self
        PrimCuisineDropdown.dataSource = self
        PrimCuisineDropdown.register(CellClass.self, forCellReuseIdentifier: "Cell")
        // Do any additional setup after loading the view
    }
    
    func addTransparentView(frames: CGRect, view: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        PrimCuisineDropdown.frame = CGRect(x: frames.origin.x + 10, y: view.origin.y + frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        self.view.addSubview(PrimCuisineDropdown)
        PrimCuisineDropdown.layer.cornerRadius = 5
                
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        PrimCuisineDropdown.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity:  1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.PrimCuisineDropdown.frame = CGRect(x: frames.origin.x + 10, y: view.origin.y + frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }

    @objc func removeTransparentView (view: CGRect) {
        let frames = selectedPrimCuisine.frame
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity:  1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.PrimCuisineDropdown.frame = CGRect(x: frames.origin.x + 10, y: self.PrefsView.frame.origin.y + frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
    }

    
    @IBAction func selectPrimCuisine(_ sender: Any) {
        dataSource = ["Indian", "Mexican", "Italian", "Chinese", "Japanese", "Other"]
        selectedPrimCuisine = btnPrimCuisine
        addTransparentView(frames: btnPrimCuisine.frame, view: PrefsView.frame)
    }
    
}

extension PrefsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPrimCuisine.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView(view: PrefsView.frame )
    }
}

class PlansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public let userTrips = UITableView()
        
    @IBOutlet weak var titleView: UIView!
    
    var tripAdditions = [String?]()
    
    
    @IBAction func revealScreen(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "add_TV") as! AddTripViewController
        
        vc.completionHandler = { text in
            self.tripDetails.append("\(text!)")
            self.userTrips.reloadData()
        }
        
        vc.completionHandler2 = { text in
            self.tripStartLocs.append("\(text!)")
            self.userTrips.reloadData()
        }
        
        present(vc, animated: true)
    }
    
    
    
    var trips = [String]()
    var tripDetails = [String]()
    var tripStartLocs = [String]()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(userTrips)
        userTrips.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        userTrips.delegate = self
        userTrips.dataSource = self
        userTrips.backgroundColor = UIColor.clear
        userTrips.allowsSelection = false
        userTrips.layer.zPosition = 1
        titleView.layer.zPosition = 2
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userTrips.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height) // location
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripDetails.count
    }
    
    let bg_image = UIImage(named: "newCell_bg.jpg")
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userTrips.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as?
                CustomTableViewCell else {fatalError("Unable to create cell")}
        
        cell.destinationlbl.text = tripDetails[indexPath.row]
        cell.startLocLbl.text = "From: \(tripStartLocs[indexPath.row])"
        let imageView = UIImageView(frame: CGRect(x: 10, y: 8, width: cell.frame.width - 20, height: 110))
        imageView.image = bg_image
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.tintColor = .black
        cell.addSubview(imageView)
        cell.sendSubviewToBack(imageView)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userTrips.deselectRow(at: indexPath, animated: true)
    }
    
}


class AddTripViewController: UIViewController {

    
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var startLocText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
    }
    
    var completionHandler: ((String?) -> Void)?
    var completionHandler2: ((String?) -> Void)?
    
    @IBAction func submitted(_ sender: Any) {
         
        completionHandler?(destinationTextField.text)
        completionHandler2?(startLocText.text)
        dismiss(animated: true, completion: nil)
    }
    
    
}







