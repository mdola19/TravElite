//
//  FindFoodMap.swift
//  TravElite
//
//  Created by Manjot Dola on 2022-07-27.
//

import UIKit
import MapKit
import CoreLocation

class FindFoodMap: UIViewController, UITextFieldDelegate, InputRouteDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!

    
    @IBAction func revealInputScreen(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "input_route") as! InputRoute
        vc.delegate = self
        present(vc, animated: true)

    }
    
    let LocationManager = CLLocationManager()
    let regionInMeters: Double  = 15000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        }
        
        checkLocationServices()

    }
    
    func setupLocationManager() {
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
//    func centreViewOnUserLocation() {
//        if let location = LocationManager.location?.coordinate {
//            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//            mapView.setRegion(region, animated: true)
//        }
//    }
    
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
    
    func InputRoute(_ vc: InputRoute, startingCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D) {
        dismiss(animated: true)
//        let pin = MKPointAnnotation()
//        pin.coordinate = coordinates
//        mapView.addAnnotation(pin)
//        mapView.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters), animated: true)
        
        
        let destinationPin = MKPointAnnotation()
        destinationPin.coordinate = destinationCoordinates
        let startLocPin = MKPointAnnotation()
        startLocPin.coordinate = startingCoordinates
        
        // Customize the annotations here later
        
        self.mapView.addAnnotation(destinationPin)
        self.mapView.addAnnotation(startLocPin)
        
        let sourcePlacemark = MKPlacemark(coordinate: startingCoordinates)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates)

        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print("Could not get directions==\(error.localizedDescription)")
                }
                
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
                
        
        self.mapView.delegate = self

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
    func InputRoute(_ vc: InputRoute, startingCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D)
    
}

class InputRoute: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: InputRouteDelegate?
    let findFoodMap = FindFoodMap()
    
    var locations = [Location]()
    var locations2 = [Location]()
    let table = UITableView()
    let table2 = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        table2.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        table2.delegate = self
        table2.dataSource = self
        table2.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
        startingLocationField.delegate = self
        destinationField.delegate = self
        view.addSubview(table2)
        view.addSubview(table)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableY: CGFloat = destinationField.frame.origin.y + destinationField.frame.size.height + 5
        let tableY2: CGFloat = startingLocationField.frame.origin.y + startingLocationField.frame.size.height + 5
        table2.frame = CGRect(x: 20, y: tableY2, width: view.frame.size.width - 40, height: 50)
        table.frame = CGRect(x: 20, y: tableY, width: view.frame.size.width - 40, height: 50)
    }
    
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var startingLocationField: UITextField!

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        startingLocationField.resignFirstResponder()
        if let text2 = startingLocationField.text, !text2.isEmpty {
            AddressManager.shared.findAddresses(with: text2) { [weak self] locations2 in
                DispatchQueue.main.async {
                    self?.locations2 = locations2
                    self?.table2.reloadData()
                }
            }
        }
        
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
        
        if tableView == table2, let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? UITableViewCell {
            cell2.textLabel?.text = locations2[indexPath.row].title
            cell2.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
            cell2.textLabel?.font = UIFont(name: "Poppins-Semibold", size: 14)
            cell2.textLabel?.numberOfLines = 0
            cell2.contentView.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            cell2.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            
            return cell2
        }
        
        if tableView == table, let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell {
            
            cell.textLabel?.text = locations[indexPath.row].title
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8820257783, blue: 0.8013891578, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Poppins-Semibold", size: 14)
            cell.textLabel?.numberOfLines = 0
            cell.contentView.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            cell.backgroundColor = #colorLiteral(red: 0.2078431845, green: 0.2078431249, blue: 0.2078431249, alpha: 1)
            
            return cell
        }

        return UITableViewCell()
    }
    
    var coordinatesArr = [CLLocationCoordinate2D]()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Notify map controller to pin location
        if tableView == table2 {
            coordinatesArr.append(locations2[indexPath.row].coordinates)
            tableView.deselectRow(at: indexPath, animated: true)
            
            delegate?.InputRoute(self, startingCoordinates: coordinatesArr[1], destinationCoordinates: coordinatesArr[0])
        }
        
        if tableView == table {
            coordinatesArr.append(locations[indexPath.row].coordinates)
            tableView.deselectRow(at: indexPath, animated: true)

            
            
            
//            func getDirections(mapView: MKMapView) {
//                let request = findFoodMap.createDirectionsRequest(from: locations2[indexPath.row].coordinates, startingPoint: coordinate)
//
//                let directions = MKDirections(request: request)
//
//                directions.calculate { [unowned self] (response, error) in
//                    guard let response = response else {return}
//                    for route in response.routes {
//                        mapView.addOverlay(route.polyline)
//                        mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//                    }
//                }
//
//            }

        }
        

        
    }
    
    
    
    
}
