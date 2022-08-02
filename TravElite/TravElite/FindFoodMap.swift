//
//  FindFoodMap.swift
//  TravElite
//
//  Created by Manjot Dola on 2022-07-27.
//

import UIKit
import MapKit
import CoreLocation

extension String {
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

struct Locations {
    var address = ""
    var city = ""
    var long = ""
    var lat = ""
    var name = ""
    var priceRange = ""
    var phoneNum = ""
    var websites = ""
    var menuURL = ""
    
    init(raw: [String]) {
        address = raw[0]
        city = raw[1]
        lat = raw[2]
        long = raw[3]
        menuURL = raw[4]
        name = raw[5]
        priceRange = raw[6]
        websites = raw[8]
        phoneNum = raw[9]
    }
}
//address,city,lat,long,menuURL,name,phones,priceRange,province,websites,,,,,,,,,,,,,,,,,,



func loadCSV(from csvName: String) -> [Locations] {
    
    var csvToStruct = [Locations]()
    
    // locate csv file
    guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {return []}
    
    // convert the contents of the file into 1 very long string
    var data = ""
    do {
        data = try String(contentsOfFile: filePath)
    } catch {
        print(error)
        return []
    }
    
    // split long string into array of rows of data. Each row is a string
    var rows = data.components(separatedBy: "\n")
    //print(rows[15])
    
    // remove title row
    rows.removeFirst()
    rows.removeLast()
    
    // now loop through each row and split into columns
    for row in rows {
        var csvColumns = row.components(separatedBy: ",")
        let locationStruct = Locations.init(raw: csvColumns)
        csvToStruct.append(locationStruct)
    }
    
    
    return csvToStruct
}

class FindFoodMap: UIViewController, UITextFieldDelegate, InputRouteDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var etaLbl: UILabel!

    @IBAction func revealInputScreen(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "input_route") as! InputRoute
        vc.delegate = self
        present(vc, animated: true)
    }
    
    let LocationManager = CLLocationManager()
    let regionInMeters: Double  = 15000
    var directionsArray: [MKDirections] = []
    var locationAnnotations = [MKPointAnnotation]()
    var locationNames = [String]()
    let bg_tint = UIView()
    var distanceToPin = 0
    var goBtn = UIButton()
    var reloadBtn = UIButton()
    var popups = [UIView]()
    var popup_titles = [UILabel]()
    var popup_subtitles = [UILabel]()
    var priceRanges = [UILabel]()
    var phoneNums = [UILabel]()
    var menuURLs = [UILabel]()
    var websites = [UILabel]()
    var locationPins = [MKPointAnnotation]()
    var user_locs = [CLLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        }
        
        var restaurauntsCSV = loadCSV(from: "myRestaurants")
    
        for i in 0 ... restaurauntsCSV.count - 1 {
            locationAnnotations.append(MKPointAnnotation())
        }


        for j in 0 ... restaurauntsCSV.count - 1 {
            let longitudes = Double(restaurauntsCSV[j].long)
            let latitudes = Double(restaurauntsCSV[j].lat)
            locationAnnotations[j].coordinate = CLLocationCoordinate2D(latitude: latitudes ?? 0, longitude: longitudes ?? 0)
            locationAnnotations[j].title = restaurauntsCSV[j].name
        }
        
        for m in 0 ... locationAnnotations.count - 1 {
            locationNames.append(restaurauntsCSV[m].name)
            popups.append(UIView.init(frame: CGRect(x: 15, y: 15, width: mapView.frame.width - 100, height: mapView.frame.height - 500)))
            popups[m].center = mapView.center
        }
        
        for popup in 0 ... popups.count - 1 {
            popups[popup].layer.cornerRadius = 15
            popups[popup].backgroundColor = UIColor.white
        }
        
        for name in 0 ... locationNames.count - 1 {
            popup_titles.append(UILabel(frame: CGRect(x: popups[name].frame.origin.x + popups[name].frame.width/2 - ((popups[name].frame.width - 20)/2), y: popups[name].frame.origin.y + 15, width: popups[name].frame.width - 20, height: 50)))
            popup_titles[name].text = locationNames[name]
            popup_titles[name].font = UIFont(name: "Poppins-Bold", size: 20)
            popup_titles[name].textAlignment = .center
            popup_titles[name].textColor = UIColor.black
            
            popup_subtitles.append(UILabel(frame: CGRect(x: popups[name].frame.origin.x + popups[name].frame.width/2 - ((popups[name].frame.width - 20)/2), y: popup_titles[name].frame.origin.y + 25, width: popups[name].frame.width - 20, height: 50)))
            popup_subtitles[name].text = restaurauntsCSV[name].address
            popup_subtitles[name].font = UIFont(name: "Poppins-Semibold", size: 12)
            popup_subtitles[name].textAlignment = .center
            popup_subtitles[name].textColor = UIColor.black
            
            priceRanges.append(UILabel(frame: CGRect(x: popups[name].frame.origin.x + popups[name].frame.width/2 - ((popups[name].frame.width - 20)/2) + 7, y: popup_subtitles[name].frame.origin.y + 45, width: popups[name].frame.width - 20, height: 50)))
            priceRanges[name].text = "Price Range: \(restaurauntsCSV[name].priceRange)"
            priceRanges[name].font = UIFont(name: "Poppins-Semibold", size: 14)
            priceRanges[name].textAlignment = .left
            priceRanges[name].textColor = UIColor.black
            
            phoneNums.append(UILabel(frame: CGRect(x: popups[name].frame.origin.x + popups[name].frame.width/2 - ((popups[name].frame.width - 20)/2) + 7, y: priceRanges[name].frame.origin.y + 35, width: popups[name].frame.width - 20, height: 50)))
            phoneNums[name].text = "Phone Number (s): \(restaurauntsCSV[name].phoneNum)"
            phoneNums[name].font = UIFont(name: "Poppins-Semibold", size: 14)
            phoneNums[name].textAlignment = .left
            phoneNums[name].textColor = UIColor.black
            
            menuURLs.append(UILabel(frame: CGRect(x: popups[name].frame.origin.x + popups[name].frame.width/2 - ((popups[name].frame.width - 20)/2) + 7, y: phoneNums[name].frame.origin.y + 35, width: popups[name].frame.width - 20, height: 50)))
            menuURLs[name].text = "Menu URL: \(restaurauntsCSV[name].menuURL)"
            menuURLs[name].font = UIFont(name: "Poppins-Semibold", size: 14)
            menuURLs[name].textAlignment = .left
            menuURLs[name].textColor = UIColor.black
            
            websites.append(UILabel(frame: CGRect(x: popups[name].frame.origin.x + popups[name].frame.width/2 - ((popups[name].frame.width - 20)/2) + 7, y: menuURLs[name].frame.origin.y + 35, width: popups[name].frame.width - 20, height: 50)))
            websites[name].text = "Website: \(restaurauntsCSV[name].websites)"
            websites[name].font = UIFont(name: "Poppins-Semibold", size: 14)
            websites[name].textAlignment = .left
            websites[name].textColor = UIColor.black
        }
        
        
        checkLocationServices()
        
        reloadBtn.frame = CGRect(x: mapView.frame.width - 45, y: 135, width: 40, height: 40)
        reloadBtn.setTitle("x", for: .normal)
        reloadBtn.setTitleColor(UIColor.black, for: .normal)
        reloadBtn.backgroundColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
        reloadBtn.layer.cornerRadius = 19
        mapView.addSubview(reloadBtn)
        
        reloadBtn.addTarget(self, action: #selector(reloadMap), for: .touchUpInside)
    
        mapView.delegate = self
        

    }
    
    var counter = 0
    
    @objc func reloadMap() {
        mapView.removeAnnotations(mapView.annotations)
        counter += 1
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            // Create the view
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let image = UIImage(named: "foodpins")
        annotationView?.image = image
        
        return annotationView
    }
    
    var currentAnnotation = CLLocationCoordinate2D()
    var currenPopup = UIView()
    var currentPopupTItle = UILabel()
    var currentPopupSubtitle = UILabel()
    var currentPriceRange = UILabel()
    var currentPhone = UILabel()
    var currentMenu = UILabel()
    var currentWebsite = UILabel()
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for annotation in 0 ... locationAnnotations.count - 1 {
            if locationAnnotations[annotation].coordinate.latitude == view.annotation?.coordinate.latitude {
                bg_tint.frame = CGRect(x: 0, y: 0, width: mapView.frame.width, height: mapView.frame.height)
                bg_tint.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                
                mapView.addSubview(bg_tint)
                mapView.addSubview(popups[annotation])
                mapView.addSubview(popup_titles[annotation])
                mapView.addSubview(popup_subtitles[annotation])
                mapView.addSubview(priceRanges[annotation])
                mapView.addSubview(phoneNums[annotation])
                mapView.addSubview(menuURLs[annotation])
                mapView.addSubview(websites[annotation])
                
                goBtn.frame = CGRect(x: popups[annotation].frame.origin.x + popups[annotation].frame.width/2 - 75, y: popups[annotation].frame.origin.y + popups[annotation].frame.height - 70, width: 150, height: 50)
                goBtn.setTitle("See Route", for: .normal)
                goBtn.setTitleColor(UIColor.black, for: .normal)
                goBtn.backgroundColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
                goBtn.layer.cornerRadius = 15
                mapView.addSubview(goBtn)
                
                goBtn.addTarget(self, action: #selector(goGetFood), for: .touchUpInside)
                
                currentAnnotation = locationAnnotations[annotation].coordinate
                currenPopup = popups[annotation]
                currentPopupTItle = popup_titles[annotation]
                currentPopupSubtitle = popup_subtitles[annotation]
                currentPriceRange = priceRanges[annotation]
                currentMenu = menuURLs[annotation]
                currentPhone = phoneNums[annotation]
                currentWebsite = websites[annotation]

            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeBg_tint))
        bg_tint.addGestureRecognizer(tapGesture)
    }
    
    @objc func goGetFood() {
        let locationPlacemark = MKPlacemark(coordinate: locationPins[counter].coordinate)
        let foodPlacemark = MKPlacemark(coordinate: currentAnnotation)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: locationPlacemark)
        directionRequest.destination = MKMapItem(placemark: foodPlacemark)
        directionRequest.transportType = .automobile
        removeBg_tint()
        
        let directions = MKDirections(request: directionRequest)
        resetMapView(withNew: directions)
        
        directions.calculate { [self] (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print("Could not get directions==\(error.localizedDescription)")
                }
                
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let eta: Int = Int(route.expectedTravelTime / 60)
            
            etaLbl.text = "ETA: \(eta) minutes"
            etaLbl.textColor = UIColor.black
            etaLbl.alpha = 1.0
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
            self.currenPopup.removeFromSuperview()
            self.currentPopupTItle.removeFromSuperview()
            self.currentPopupSubtitle.removeFromSuperview()
            self.goBtn.removeFromSuperview()
            self.bg_tint.removeFromSuperview()
            self.currentPriceRange.removeFromSuperview()
            self.currentPhone.removeFromSuperview()
            self.currentMenu.removeFromSuperview()
            self.currentWebsite.removeFromSuperview()
        }
                
        
        self.mapView.delegate = self
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        
    }
    
    @objc func removeBg_tint () {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity:  1.0, options: .curveEaseInOut, animations: {
            for i in 0 ... self.popups.count - 1 {
                self.popups[i].removeFromSuperview()
                self.popup_titles[i].removeFromSuperview()
                self.priceRanges[i].removeFromSuperview()
                self.popup_subtitles[i].removeFromSuperview()
                self.goBtn.removeFromSuperview()
                self.websites[i].removeFromSuperview()
                self.phoneNums[i].removeFromSuperview()
                self.menuURLs[i].removeFromSuperview()

            }
            
            self.bg_tint.removeFromSuperview()
        }, completion: nil)
    }
    
    func setupLocationManager() {
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        
        else {
           // show alert to turn on location services
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            //centreViewOnUserLocation()
            LocationManager.startUpdatingLocation()
            break
        case .denied:
            // show alert to instruct how to permit the app
            break
        case .notDetermined:
            LocationManager.requestWhenInUseAuthorization()
        case .restricted:
            // show alert
            break
        case .authorizedAlways:
            break
        }
    }
    
    func InputRoute(_ vc: InputRoute, locationCoordinates: CLLocationCoordinate2D) {
        dismiss(animated: true)
        
        locationPins.append(MKPointAnnotation())
        locationPins[counter].coordinate = locationCoordinates
        
        mapView.setRegion(MKCoordinateRegion(center: locationPins[counter].coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000), animated: true)
                            
        self.mapView.addAnnotation(locationPins[counter])
                
        user_locs.append(CLLocation(latitude: locationPins[counter].coordinate.latitude, longitude: locationPins[counter].coordinate.longitude))
                
        for m in 0 ... locationAnnotations.count - 1 {
            let pinLoc = CLLocation(latitude: locationAnnotations[m].coordinate.latitude, longitude: locationAnnotations[m].coordinate.longitude)
            distanceToPin = Int(user_locs[counter].distance(from: pinLoc))
            
            if distanceToPin < 10000 {
                self.mapView.addAnnotation(locationAnnotations[m])
            }
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
        renderer.lineWidth = 7.0
        
        return renderer
    }
    
    
    
    
    
//    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, startingPoint: CLLocationCoordinate2D) -> MKDirections.Request {
//        let destinationCoordinate = coordinate
//        let startingLocation = MKPlacemark(coordinate: startingPoint)
//        let destination = MKPlacemark(coordinate: destinationCoordinate)
//
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: startingLocation)
//        request.destination = MKMapItem(placemark: destination)
//        request.transportType = .automobile
//        request.requestsAlternateRoutes = true
//
//        return request
//    }
    
}

extension FindFoodMap: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         checkLocationAuthorization()
        
        
    }
    
}

protocol InputRouteDelegate: AnyObject {
    func InputRoute(_ vc: InputRoute, locationCoordinates: CLLocationCoordinate2D)
    
}

class InputRoute: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: InputRouteDelegate?
    let findFoodMap = FindFoodMap()
    
    var locations = [Location]()
    let table = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        destinationField.delegate = self
        view.addSubview(table)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableY: CGFloat = destinationField.frame.origin.y + destinationField.frame.size.height + 5
        table.frame = CGRect(x: 20, y: tableY, width: view.frame.size.width - 40, height: 50)
    }
    
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var startingLocationField: UITextField!

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        destinationField.resignFirstResponder()
        if let text = destinationField.text, !text.isEmpty {
            AddressManager.shared.findAddresses(with: text) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.table.reloadData()
                }
            }
        }
        
        return true
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Poppins-Semibold", size: 14)
        cell.textLabel?.numberOfLines = 0
        cell.contentView.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        
        return cell
    }
    
    var coordinatesArr = [CLLocationCoordinate2D]()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == table {
            coordinatesArr.append(locations[indexPath.row].coordinates)
            delegate?.InputRoute(self, locationCoordinates: coordinatesArr[0])

            tableView.deselectRow(at: indexPath, animated: true)

        }
        
    }
    
}
