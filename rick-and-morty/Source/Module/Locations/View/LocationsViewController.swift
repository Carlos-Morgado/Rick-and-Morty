//
//  LocationsViewController.swift
//  rick-and-morty
//
//  Created by Carlos Morgado on 14/8/23.
//

import UIKit

protocol LocationsView: AnyObject {
    // Presenter -> View
    func reloadLocations()
}


final class LocationsViewController: UIViewController {

    var presenter: LocationsPresenter?
    
    private lazy var locationsSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "locations_searchbar_placeholder".localized
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.barTintColor = .clear
        searchBar.tintColor = .mainGreen1
        searchBar.searchTextField.textColor = .white
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            let placeholderColor = UIColor.mainBlue1
            let placeholderText = "locations_searchbar_placeholder".localized
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor as Any])
        }
        if let magnifyingGlassImage = UIImage(named: "lupa") {
            searchBar.setImage(magnifyingGlassImage, for: .search, state: .normal)
        }
        return searchBar
    }()
    
    private lazy var locationsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        presenter?.viewDidLoad()
    }
}

// MARK: - CONFIG VIEW

extension LocationsViewController: LocationsView {
    
    func reloadLocations() {
        locationsTableView.reloadData()
    }
}

private extension LocationsViewController {
    
    func configView() {
        title = "locations_screen_navigation_title".localized
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = .mainBackgroundColor1
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.backgroundColor = .mainBackgroundColor1
        view.addSubview(locationsSearchBar)
        NSLayoutConstraint.activate([
            locationsSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            locationsSearchBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            locationsSearchBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            locationsSearchBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addSubview(locationsTableView)
        configLocationsTableView()
        NSLayoutConstraint.activate([
            locationsTableView.topAnchor.constraint(equalTo: locationsSearchBar.bottomAnchor, constant: 5),
            locationsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            locationsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            locationsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func configLocationsTableView() {
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        locationsTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
        locationsTableView.isScrollEnabled = true
        locationsTableView.backgroundColor = .clear
        locationsTableView.layer.cornerRadius = 0
    }
}

// MARK: - EXTENSIONS

extension LocationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.locations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = locationsTableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier) as? LocationTableViewCell, let location = presenter?.locations[indexPath.row] else {
            return UITableViewCell()
        }
        cell.setCellLabelTexts(setLocationName: location.name, setLocationType: location.type)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Obtén la altura del contenido de la tabla
        let contenidoTablaAltura = locationsTableView.contentSize.height
        
        // Obtén la posición actual de desplazamiento
        let posicionDesplazamiento = locationsTableView.contentOffset.y
        
        // Obtén la altura de la vista visible
        let vistaAltura = locationsTableView.frame.size.height
        
        // Determina cuántos puntos faltan para llegar al final
        let puntosRestantes = contenidoTablaAltura - (posicionDesplazamiento + vistaAltura)
        
        // Define una constante para determinar cuántos puntos se consideran "cerca del final"
        let puntosCercaDelFinal: CGFloat = 100.0 // Ajusta este valor según tus necesidades
        
        if puntosRestantes < puntosCercaDelFinal {
            // Estás cerca del final de la tabla
            // Puedes cargar más datos o realizar la acción que desees aquí
            presenter?.getLocations()
        }
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectRowAt(indexPath)
    }
}

extension LocationsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            // Aquí puedes realizar alguna acción con el término de búsqueda, como buscar en una base de datos o realizar alguna otra tarea relacionada.
            presenter?.searchBarSearchButtonClicked(searchText: searchText)
        }
        searchBar.resignFirstResponder() // Oculta el teclado
    }
}
