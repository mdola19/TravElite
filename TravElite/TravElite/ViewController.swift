//
//  ViewController.swift
//  TravElite
//
//  Created by Manjot Dola on 2022-07-22.
//

import UIKit
import CoreLocation
import MapKit

class Coordinates {
    
    //creates the instance and guarantees that it's unique
    static let instance = Coordinates()
    
    private init() {
    }
    
    //creates the global variable
    var locations = [Location]()
    var locations2 = [Location]()
    var currentCoordiante = 0
    var cellNumbers = [Int]()
    var currentCell = 0
    var tripCost: Double = 0
}

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
    
    var popup = UIView()
    var popupText = UILabel()
    var bg_tint = UIView()
    
    @IBAction func submitBtn(_ sender: Any) {
        view.addSubview(bg_tint)
        view.addSubview(popup)
        view.addSubview(popupText)
    }
    
    let transparentView = UIView()
    let PrimCuisineDropdown = UITableView()
    
    var selectedPrimCuisine = UIButton()
    
    var dataSource = [String]()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        PrimCuisineDropdown.delegate = self
        PrimCuisineDropdown.dataSource = self
        PrimCuisineDropdown.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        bg_tint.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        bg_tint.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        popup.frame = CGRect(x: 45, y: 400, width: view.frame.width - 100, height: 200)
        popup.layer.cornerRadius = 10
        popup.backgroundColor = UIColor.white
        
        popupText.frame = CGRect(x: 0, y: 0, width: popup.frame.width - 20, height: 50)
        popupText.center = popup.center
        popupText.text = "Preferences Updated"
        popupText.font = UIFont(name: "Poppins-Bold", size: 18)
        popupText.textAlignment = .center
        popupText.textColor = UIColor.black
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePopup))
        bg_tint.addGestureRecognizer(gestureRecognizer)
    
        // Do any additional setup after loading the view
    }
    
    @objc func removePopup() {
        bg_tint.removeFromSuperview()
        popup.removeFromSuperview()
        popupText.removeFromSuperview()
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
        let imageView = UIImageView(frame: CGRect(x: 29, y: 8, width: 365, height: 110))
        imageView.image = bg_image
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.tintColor = .black
        cell.addSubview(imageView)
        cell.sendSubviewToBack(imageView)
        Coordinates.instance.cellNumbers.append(indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userTrips.deselectRow(at: indexPath, animated: true)
        Coordinates.instance.currentCell = indexPath.row
        let mapVC = storyboard?.instantiateViewController(withIdentifier: "tripMap") as! showTripMap
        present(mapVC, animated: true)
    }
    
    
}


class AddTripViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startLocText: UITextField!
    
    let table = UITableView()
    let table2 = UITableView()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        destinationTextField.resignFirstResponder()
        if let text = destinationTextField.text, !text.isEmpty {
            AddressManager.shared.findAddresses(with: text) { [weak self] locations in
                DispatchQueue.main.async {
                    Coordinates.instance.locations = locations
                    self?.table.reloadData()
                }
            }
        }
        
        startLocText.resignFirstResponder()
        if let text = startLocText.text, !text.isEmpty {
            AddressManager.shared.findAddresses(with: text) { [weak self] locations2 in
                DispatchQueue.main.async {
                    Coordinates.instance.locations2 = locations2
                    self?.table2.reloadData()
                }
            }
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        destinationTextField.delegate = self
        view.addSubview(table)
        
        table2.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table2.delegate = self
        table2.dataSource = self
        table2.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        startLocText.delegate = self
        view.addSubview(table2)
        // Do any additional setup after loading the view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableY: CGFloat = destinationTextField.frame.origin.y + destinationTextField.frame.size.height + 5
        let tableY2: CGFloat = startLocText.frame.origin.y + destinationTextField.frame.size.height + 5
        table.frame = CGRect(x: 20, y: tableY, width: view.frame.size.width - 40, height: 50)
        table2.frame = CGRect(x: 20, y: tableY2, width: view.frame.size.width - 40, height: 50)
    }
    
    var completionHandler: ((String?) -> Void)?
    var completionHandler2: ((String?) -> Void)?
    var completionHandlerStartLat: ((String?) -> Void)?
    var completionHandlerStartLong: ((String?) -> Void)?
    var completionHandlerDestinationLat: ((String?) -> Void)?
    var completionHandlerDestinationLong: ((String?) -> Void)?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Coordinates.instance.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == table {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
                
            cell.textLabel?.text = Coordinates.instance.locations[indexPath.row].title
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Poppins-Semibold", size: 14)
            cell.textLabel?.numberOfLines = 0
            cell.contentView.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            cell.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            
            return cell
        }
        
        if tableView == table2 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            
            cell2.textLabel?.text = Coordinates.instance.locations2[indexPath.row].title
            cell2.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
            cell2.textLabel?.font = UIFont(name: "Poppins-Semibold", size: 14)
            cell2.textLabel?.numberOfLines = 0
            cell2.contentView.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            cell2.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            
            return cell2
        }
        
        return UITableViewCell()
    }
    
    var coordinatesArr = [CLLocationCoordinate2D]()
    var coordinatesArr2 = [CLLocationCoordinate2D]()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == table {
            coordinatesArr.append(Coordinates.instance.locations[indexPath.row].coordinates)
//            delegate?.InputRoute(self, locationCoordinates: coordinatesArr[0])
            tableView.deselectRow(at: indexPath, animated: true)

        }
        
        if tableView == table2 {
            coordinatesArr2.append(Coordinates.instance.locations2[indexPath.row].coordinates)
            completionHandler?(destinationTextField.text)
            completionHandler2?(startLocText.text)
            Coordinates.instance.currentCoordiante = indexPath.row
            completionHandlerStartLat?(String(Coordinates.instance.locations2[indexPath.row].coordinates.latitude))
            completionHandlerStartLong?(String(Coordinates.instance.locations2[indexPath.row].coordinates.longitude))
            completionHandlerDestinationLat?(String(Coordinates.instance.locations2[indexPath.row].coordinates.latitude))
            completionHandlerDestinationLong?(String(Coordinates.instance.locations2[indexPath.row].coordinates.longitude))
//            delegate?.InputRoute(self, locationCoordinates: coordinatesArr[0])
            tableView.deselectRow(at: indexPath, animated: true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    

    
}

class showTripMap: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var etaLbl: UILabel!
    var directionsArray: [MKDirections] = []
    
    var popup = UIView()
    var popupText = UILabel()
    var cost = UILabel()
    var bg_tint = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        }
        
        bg_tint.frame = CGRect(x: 0, y: 0, width: mapView.frame.width + 50, height: mapView.frame.height)
        bg_tint.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        popup.frame = CGRect(x: 15, y: 0, width: view.frame.width - 100, height: 200)
        popup.center = mapView.center
        popup.layer.cornerRadius = 10
        popup.backgroundColor = UIColor.white
        
        popupText.frame = CGRect(x: popup.frame.origin.x + popup.frame.width/2 - (popup.frame.width - 20)/2, y: popup.frame.origin.y + 50, width: popup.frame.width - 20, height: 50)
        popupText.text = "Estimated Fuel Cost:"
        popupText.font = UIFont(name: "Poppins-Bold", size: 18)
        popupText.textAlignment = .center
        popupText.textColor = UIColor.black
        
        cost.frame = CGRect(x: popup.frame.origin.x + popup.frame.width/2 - (popup.frame.width - 20)/2, y: popupText.frame.origin.y + 30, width: popup.frame.width - 20, height: 50)
        cost.font = UIFont(name: "Poppins-Regular", size: 14)
        cost.textAlignment = .center
        cost.textColor = UIColor.black
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePopup))
        bg_tint.addGestureRecognizer(gestureRecognizer)
        
        getDirections()
    }
    
    @objc func removePopup() {
        bg_tint.removeFromSuperview()
        popup.removeFromSuperview()
        popupText.removeFromSuperview()
        cost.removeFromSuperview()
    }
    
    @IBAction func showRoute(_ sender: Any) {
        dismiss(animated: true)
    }
    

    func getDirections() {
        let index = Coordinates.instance.cellNumbers[Coordinates.instance.currentCell]

        let sourcePlacemark = MKPlacemark(coordinate: Coordinates.instance.locations2[Coordinates.instance.currentCoordiante].coordinates)
        let destinationPlacemark = MKPlacemark(coordinate: Coordinates.instance.locations[Coordinates.instance.currentCoordiante].coordinates)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let sourceLoc = CLLocation(latitude: sourcePlacemark.coordinate.latitude, longitude: sourcePlacemark.coordinate.longitude)
        let destinationLoc = CLLocation(latitude: destinationPlacemark.coordinate.latitude, longitude: destinationPlacemark.coordinate.longitude)
        
        let distance = destinationLoc.distance(from: sourceLoc)/1000

        Coordinates.instance.tripCost = distance * 0.16275
        
        print(Coordinates.instance.tripCost)
        

        let directions = MKDirections(request: directionRequest)
        resetMapView(withNew: directions)

        directions.calculate { [self] (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print("Could not get directions==\(error.localizedDescription)")
                }

                return
            }
            
            let route = directionResponse.routes[index]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let eta: Int = Int(route.expectedTravelTime / 60 / 60)

            etaLbl.text = "ETA: \(eta) hours"
            etaLbl.textColor = UIColor.black
            etaLbl.alpha = 1.0

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }


        self.mapView.delegate = self
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
        renderer.lineWidth = 7.0
        
        return renderer
    }
    
    @IBAction func fuelCost(_ sender: Any) {
        mapView.addSubview(bg_tint)
        mapView.addSubview(popup)
        mapView.addSubview(popupText)
        cost.text = "$\(String(format: "%.2f", ceil(Coordinates.instance.tripCost*100)/100))"
        mapView.addSubview(cost)

    }
    
}





